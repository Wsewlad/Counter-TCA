//
//  Reducer.swift
//  Counter-TCA
//
//  Created by  Vladyslav Fil on 23.09.2022.
//

import Foundation

func appReducer(state: inout AppState, action: AppAction) {
    switch action {
    case .counter(.decrTapped):
        state.count -= 1
    case .counter(.incrTapped):
        state.count += 1
        
    case .primeModal(.saveFavoritePrimeTapped):
        state.favoritePrimes.append(state.count)
        state.activityFeed.append(.init(timestamp: .now, type: .addedFavoritePrime(state.count)))
    case .primeModal(.removeFavoritePrimeTapped):
        state.favoritePrimes.remove(state.count)
        state.activityFeed.append(.init(timestamp: .now, type: .removeFavoritePrime(state.count)))
        
    case .favoritePrimes(.deleteFavoritePrimes(let indexSet)):
        for index in indexSet {
            state.favoritePrimes.remove(at: index)
            state.activityFeed.append(.init(timestamp: .now, type: .removeFavoritePrime(self.count)))
        }
    }
}
