//
//  FavoritePrimes.swift
//  FavoritePrimes
//
//  Created by  Vladyslav Fil on 24.09.2022.
//

import Foundation
import Collections

public enum FavoritePrimesAction {
    case deleteFavoritePrimes(IndexSet)
}

public func favoritePrimesReducer(state: inout OrderedSet<Int>, action: FavoritePrimesAction) {
    switch action {
    case .deleteFavoritePrimes(let indexSet):
        for index in indexSet {
            state.remove(at: index)
        }
    }
}
