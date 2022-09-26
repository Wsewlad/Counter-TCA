//
//  ComposableArchitecture.swift
//  ComposableArchitecture
//
//  Created by  Vladyslav Fil on 24.09.2022.
//

import SwiftUI
import Combine

public final class Store<State, Action>: ObservableObject {
    private let reducer: (inout State, Action) -> Void
    @Published public private(set) var state: State
    
    public init(state: State, reducer: @escaping (inout State, Action) -> Void) {
        self.state = state
        self.reducer = reducer
    }
    
    public func send(_ action: Action) {
        self.reducer(&self.state, action)
    }
}

extension Store {
    func view<LocalState>(
        _ f: @escaping (State) -> LocalState
    ) -> Store<LocalState, Action> {
        return Store<LocalState, Action>(
            state: f(self.state),
            reducer: { localState, action  in
                self.send(action)
                localState = f(self.state)
            }
        )
    }
}

//MARK: - combine
public func combine<State, Action>(
  _ reducers: (inout State, Action) -> Void...
) -> (inout State, Action) -> Void {
    return { state, action in
        reducers.forEach { reducer in
            reducer(&state, action)
        }
    }
}

//MARK: - transform
public func transform<GlobalState, LocalState, GlobalAction, LocalAction>(
    _ localReducer: @escaping (inout LocalState, LocalAction) -> Void,
    state: WritableKeyPath<GlobalState, LocalState>,
    action: WritableKeyPath<GlobalAction, LocalAction?>
) -> (inout GlobalState, GlobalAction) -> Void {
    return { globalState, globalAction in
        guard let localAction = globalAction[keyPath: action] else { return }
        localReducer(&globalState[keyPath: state], localAction)
    }
}

//MARK: - logging
public func logging<State, Action>(
  _ reducer: @escaping (inout State, Action) -> Void
) -> (inout State, Action) -> Void {
    return { state, action in
        reducer(&state, action)
        print("Action: \(action)")
        print("State:")
        dump(state)
        print("---")
    }
}

//MARK: - filter Actions
public func filterActions<State, Action>(_ predicate: @escaping (Action) -> Bool)
  -> (@escaping (inout State, Action) -> Void)
  -> (inout State, Action) -> Void {
      return { reducer in
          return { state, action in
              if predicate(action) {
                  reducer(&state, action)
              }
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

func undo<Value, Action>(
    _ reducer: @escaping (inout Value, Action) -> Void,
    limit: Int
) -> (inout UndoState<Value>, UndoAction<Action>) -> Void {
    return { undoState, undoAction in
        switch undoAction {
        case let .action(action):
            var currentState = undoState.state
            reducer(&currentState, action)
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
