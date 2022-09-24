//
//  Reducer.swift
//  Counter-TCA
//
//  Created by  Vladyslav Fil on 23.09.2022.
//

import Foundation
import Collections

func counterReducer(state: inout Int, action: CounterAction) {
    switch action {
    case .decrTapped:
        state -= 1
    case .incrTapped:
        state += 1
    }
}

func primeModalReducer(state: inout AppState, action: PrimeModalAction) {
    switch action {
    case .saveFavoritePrimeTapped:
        state.favoritePrimesState.favoritePrimes.append(state.count)
    case .removeFavoritePrimeTapped:
        state.favoritePrimesState.favoritePrimes.remove(state.count)
    }
}

func favoritePrimesReducer(state: inout FavoritePrimesState, action: FavoritePrimesAction) {
    switch action {
    case .deleteFavoritePrimes(let indexSet):
        for index in indexSet {
            state.favoritePrimes.remove(at: index)
        }
    }
}
