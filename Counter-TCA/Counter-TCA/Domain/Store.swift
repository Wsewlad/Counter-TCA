//
//  Store.swift
//  Counter-TCA
//
//  Created by  Vladyslav Fil on 23.09.2022.
//

import SwiftUI

final class Store<State, Action>: ObservableObject {
    let reducer: (inout State, Action) -> Void
    @Published var state: State
    
    init(state: State, reducer: @escaping (inout State, Action) -> Void) {
        self.state = state
        self.reducer = reducer
    }
    
    func send(_ action: Action) {
        self.reducer(&self.state, action)
    }
}

func combine<State, Action>(
  _ reducers: (inout State, Action) -> Void...
) -> (inout State, Action) -> Void {
    return { state, action in
        reducers.forEach { reducer in
            reducer(&state, action)
        }
    }
}

func transform<GlobalState, LocalState, Action>(
  _ localReducer: @escaping (inout LocalState, Action) -> Void,
  localValueKeyPath: WritableKeyPath<GlobalState, LocalState>
) -> (inout GlobalState, Action) -> Void {
  return { globalValue, action in
    localReducer(&globalValue[keyPath: localValueKeyPath], action)
  }
}
