//
//  ComposableArchitecture.swift
//  ComposableArchitecture
//
//  Created by  Vladyslav Fil on 24.09.2022.
//

import SwiftUI
import Combine

//MARK: - Effect
public struct Effect<Output>: Publisher {
    public typealias Failure = Never
    
    let publisher: AnyPublisher<Output, Failure>
    
    public func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Output == S.Input {
        self.publisher.receive(subscriber: subscriber)
    }
}

extension Publisher where Failure == Never {
    public func eraseToEffect() -> Effect<Output> {
        return Effect(publisher: self.eraseToAnyPublisher())
    }
}

extension Effect {
    public static func fireAndForget(work: @escaping () -> Void) -> Effect {
        return Deferred { () -> Empty<Output, Never> in
            work()
            return Empty(completeImmediately: true)
        }.eraseToEffect()
    }
}

extension Effect {
    public static func sync(work: @escaping () -> Output) -> Effect {
        return Deferred {
            Just(work())
        }.eraseToEffect()
    }
}

extension Effect {
    static func async(
        work: @escaping (@escaping (Output) -> Void) -> Void
    ) -> Effect {
        return Deferred {
            Future { callback in
                work { output in
                    callback(.success(output))
                }
            }
        }
        .eraseToEffect()
    }
}

extension Publisher {
    func hush() -> Effect<Output> {
        return self
          .map(Optional.some)
          .replaceError(with: nil)
          .compactMap { $0 }
          .eraseToEffect()
    }
}

//MARK: - Reducer
public typealias Reducer<State, Action> = (inout State, Action) -> [Effect<Action>]

//MARK: - Store
public final class Store<State, Action>: ObservableObject {
    private let reducer: Reducer<State, Action>
    @Published public private(set) var state: State
    private var viewCancellable: Cancellable?
    private var effectCancellables: Set<AnyCancellable> = []
    
    public init(state: State, reducer: @escaping Reducer<State, Action>) {
        self.state = state
        self.reducer = reducer
    }
    
    public func send(_ action: Action) {
        let effects = self.reducer(&self.state, action)
        effects.forEach { effect in
            var effectCancellable: AnyCancellable?
            var didComplete = false
            effectCancellable = effect.sink(
                receiveCompletion: { [weak self] _ in
                    didComplete = true
                    guard let effectCancellable = effectCancellable else { return }
                    self?.effectCancellables.remove(effectCancellable)
                },
                receiveValue: self.send
            )
            if !didComplete, let effectCancellable = effectCancellable {
                self.effectCancellables.insert(effectCancellable)
            }
        }
    }
}

//MARK: - view
extension Store {
    public func view<LocalState, LocalAction>(
        state toLocalState: @escaping (State) -> LocalState,
        action toGlobalAction: @escaping (LocalAction) -> Action
    ) -> Store<LocalState, LocalAction> {
        let localStore = Store<LocalState, LocalAction>(
            state: toLocalState(self.state),
            reducer: { localState, localAction  in
                self.send(toGlobalAction(localAction))
                localState = toLocalState(self.state)
                return []
            }
        )
        localStore.viewCancellable = self.$state.sink { [weak localStore] newState in
            localStore?.state = toLocalState(newState)
        }
        return localStore
    }
}

//MARK: - combine
public func combine<State, Action>(
  _ reducers: Reducer<State, Action>...
) -> Reducer<State, Action> {
    return { state, action in
        let effects = reducers.flatMap { $0(&state, action) }
        return effects
    }
}

//MARK: - pullback
public func pullback<GlobalState, LocalState, GlobalAction, LocalAction>(
    _ localReducer: @escaping Reducer<LocalState, LocalAction>,
    state: WritableKeyPath<GlobalState, LocalState>,
    action: WritableKeyPath<GlobalAction, LocalAction?>
) -> Reducer<GlobalState, GlobalAction> {
    return { globalState, globalAction in
        guard let localAction = globalAction[keyPath: action] else { return [] }
        let localEffects = localReducer(&globalState[keyPath: state], localAction)
        
        return localEffects.map { localEffect in
            localEffect.map { localAction -> GlobalAction in
                var globalAction = globalAction
                globalAction[keyPath: action] = localAction
                return globalAction
            }
            .eraseToEffect()
        }
    }
}

//MARK: - logging
public func logging<State, Action>(
  _ reducer: @escaping Reducer<State, Action>
) -> Reducer<State, Action> {
    return { state, action in
        let effects = reducer(&state, action)
        let newState = state
        return [
            .fireAndForget {
                print("Action: \(action)")
                print("State:")
                dump(newState)
                print("---")
            }
        ] + effects
    }
}

//MARK: - filter Actions
public func filterActions<State, Action>(_ predicate: @escaping (Action) -> Bool)
  -> (@escaping Reducer<State, Action>)
  -> Reducer<State, Action> {
      return { reducer in
          return { state, action in
              if predicate(action) {
                  return reducer(&state, action)
              }
              return []
          }
      }
}

//MARK: - Undo / Redo
struct UndoState<State> {
    var state: State
    var history: [State]
    var undone: [State]
    var canUndo: Bool { !self.history.isEmpty }
    var canRedo: Bool { !self.undone.isEmpty }
}

enum UndoAction<Action> {
    case action(Action)
    case undo
    case redo
}

func undo<State, Action>(
    _ reducer: @escaping Reducer<State, Action>,
    limit: Int
) -> (inout UndoState<State>, UndoAction<Action>) -> Void {
    return { undoState, undoAction in
        switch undoAction {
        case let .action(action):
            var currentState = undoState.state
            let effects = reducer(&currentState, action)
            
            undoState.history.append(currentState)
            undoState.undone = []
            
            if undoState.history.count > limit {
                undoState.history.removeFirst()
            }
        case .undo:
            guard undoState.canUndo else { return }
            undoState.undone.append(undoState.state)
            undoState.state = undoState.history.removeLast()
        case .redo:
            guard undoState.canRedo else { return }
            undoState.history.append(undoState.state)
            undoState.state = undoState.undone.removeFirst()
        }
    }
}
