//
//  Model.swift
//  Counter-TCA
//
//  Created by  Vladyslav Fil on 22.09.2022.
//

import Foundation
import SwiftUI
import Collections
import PrimeModal

struct AppState {
    var count: Int = 0
    var favoritePrimes: OrderedSet<Int> = []
    var loggedInUser: User? = nil
    var activityFeed: [Activity] = []
}

extension AppState {
    var primeModal: PrimeModalState {
        get {
            (self.count, favoritePrimes: self.favoritePrimes)
        }
        set {
            self.count = newValue.count
            self.favoritePrimes = newValue.favoritePrimes
        }
    }
}

//MARK: - activity Feed
func activityFeed(
    _ reducer: @escaping (inout AppState, AppAction) -> Void
) -> (inout AppState, AppAction) -> Void {
    return { state, action in
        switch action {
        case .counter:
            break

        case .primeModal(.removeFavoritePrimeTapped):
            state.activityFeed.append(
                .init(timestamp: Date(), type: .removedFavoritePrime(state.count))
            )

        case .primeModal(.saveFavoritePrimeTapped):
            state.activityFeed.append(
                .init(timestamp: Date(), type: .saveFavoritePrimeTapped(state.count))
            )

        case let .favoritePrimes(.deleteFavoritePrimes(indexSet)):
            for index in indexSet {
                state.activityFeed.append(
                    .init(
                        timestamp: Date(),
                        type: .removedFavoritePrime(state.favoritePrimes[index])
                    )
                )
            }
        }
        
        reducer(&state, action)
    }
}
