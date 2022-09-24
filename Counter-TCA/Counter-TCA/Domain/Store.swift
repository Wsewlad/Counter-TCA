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

func transform<GlobalState, LocalState, GlobalAction, LocalAction>(
    _ localReducer: @escaping (inout LocalState, LocalAction) -> Void,
    state: WritableKeyPath<GlobalState, LocalState>,
    action: WritableKeyPath<GlobalAction, LocalAction?>
) -> (inout GlobalState, GlobalAction) -> Void {
    return { globalState, globalAction in
        guard let localAction = globalAction[keyPath: action] else { return }
        localReducer(&globalState[keyPath: state], localAction)
    }
}

func logging<State, Action>(
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


func activityFeed(
  _ reducer: @escaping (inout AppState, AppAction) -> Void
) -> (inout AppState, AppAction) -> Void {
    return { state, action in
        switch action {
        case .counter:
            break

        case .primeModal(.removeFavoritePrimeTapped):
            state.favoritePrimesState.activityFeed.append(
                .init(timestamp: Date(), type: .removedFavoritePrime(state.count))
            )

        case .primeModal(.saveFavoritePrimeTapped):
            state.favoritePrimesState.activityFeed.append(
                .init(timestamp: Date(), type: .saveFavoritePrimeTapped(state.count))
            )

        case let .favoritePrimes(.deleteFavoritePrimes(indexSet)):
            for index in indexSet {
                state.favoritePrimesState.activityFeed.append(
                    .init(
                        timestamp: Date(),
                        type: .removedFavoritePrime(state.favoritePrimesState.favoritePrimes[index])
                    )
                )
            }
        }
        
        reducer(&state, action)
    }
}
