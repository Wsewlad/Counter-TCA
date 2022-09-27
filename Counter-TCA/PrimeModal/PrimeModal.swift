//
//  PrimeModal.swift
//  PrimeModal
//
//  Created by  Vladyslav Fil on 24.09.2022.
//

import Foundation
import Collections

public typealias PrimeModalState = (count: Int, favoritePrimes: OrderedSet<Int>)

//public struct PrimeModalState {
//    public var count: Int
//    public var favoritePrimes: OrderedSet<Int>
//    
//    public init(count: Int,favoritePrimes: OrderedSet<Int>) {
//        self.count = count
//        self.favoritePrimes = favoritePrimes
//    }
//}

public enum PrimeModalAction {
    case saveFavoritePrimeTapped
    case removeFavoritePrimeTapped
}

public func primeModalReducer(state: inout PrimeModalState, action: PrimeModalAction) {
    switch action {
    case .saveFavoritePrimeTapped:
        state.favoritePrimes.append(state.count)
    case .removeFavoritePrimeTapped:
        state.favoritePrimes.remove(state.count)
    }
}
