//
//  Reducer.swift
//  Counter-TCA
//
//  Created by  Vladyslav Fil on 23.09.2022.
//

import Foundation
import Collections

func counterReducer(state: inout Int, action: AppAction) {
    switch action {
    case .counter(.decrTapped):
        state -= 1
    case .counter(.incrTapped):
        state += 1
    default:
        break
    }
}

func primeModalReducer(state: inout AppState, action: AppAction) {
    switch action {
    case .primeModal(.saveFavoritePrimeTapped):
        state.favoritePrimesState.favoritePrimes.append(state.count)
        state.favoritePrimesState.activityFeed.append(.init(timestamp: .now, type: .addedFavoritePrime(state.count)))
        
    case .primeModal(.removeFavoritePrimeTapped):
        state.favoritePrimesState.favoritePrimes.remove(state.count)
        state.favoritePrimesState.activityFeed.append(.init(timestamp: .now, type: .removeFavoritePrime(state.count)))
        
    default:
        break
    }
}

func favoritePrimesReducer(state: inout FavoritePrimesState, action: AppAction) {
    switch action {
    case .favoritePrimes(.deleteFavoritePrimes(let indexSet)):
        for index in indexSet {
            let prime = state.favoritePrimes[index]
            state.favoritePrimes.remove(at: index)
            state.activityFeed.append(.init(timestamp: .now, type: .removeFavoritePrime(prime)))
        }
    default:
        break
    }
}
