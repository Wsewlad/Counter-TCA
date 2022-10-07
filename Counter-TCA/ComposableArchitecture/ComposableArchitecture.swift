//
//  ComposableArchitecture.swift
//  ComposableArchitecture
//
//  Created by  Vladyslav Fil on 24.09.2022.
//

import SwiftUI
import Combine

public struct Effect<A> {
    public let run: (@escaping (A) -> Void) -> Void
    
    public init(run: @escaping (@escaping (A) -> Void) -> Void) {
        self.run = run
    }
    
    public func map<B>(_ f: @escaping (A) -> B) -> Effect<B> {
        return Effect<B> { callback in self.run { a in callback(f(a)) } }
    }
}

public typealias Reducer<State, Action> = (inout State, Action) -> [Effect<Action>]

public final class Store<State, Action>: ObservableObject {
    private let reducer: Reducer<State, Action>
    @Published public private(set) var state: State
    private var cancellable: Cancellable?
    
    public init(state: State, reducer: @escaping Reducer<State, Action>) {
        self.state = state
        self.reducer = reducer
    }
    
    public func send(_ action: Action) {
        let effects = self.reducer(&self.state, action)
        effects.forEach { effect in
            effect.run(self.send)
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
        localStore.cancellable = self.$state.sink { [weak localStore] newState in
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
            Effect { callback in
                localEffect.run { localAction in
                    var globalAction = globalAction
                    globalAction[keyPath: action] = localAction
                    callback(globalAction)
                }
            }
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
        return [ Effect { _ in
            print("Action: \(action)")
            print("State:")
            dump(newState)
            print("---")
        }] + effects
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
