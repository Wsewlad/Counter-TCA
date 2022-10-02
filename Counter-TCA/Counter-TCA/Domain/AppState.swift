//
//  Model.swift
//  Counter-TCA
//
//  Created by  Vladyslav Fil on 22.09.2022.
//

import Foundation
import SwiftUI
import OrderedCollections
import Counter

struct AppState {
    var count: Int = 0
    var favoritePrimes: OrderedSet<Int> = []
    var loggedInUser: User? = nil
    var activityFeed: [Activity] = []
}

//MARK: - KeyPath
extension AppState {
    var counterView: CounterViewState {
        get {
            CounterViewState(
                count: self.count,
                favoritePrimes: self.favoritePrimes
            )
        }
        set {
            self.count = newValue.count
            self.favoritePrimes = newValue.favoritePrimes
        }
    }
}

//MARK: - Models
extension AppState {
    struct Activity {
        let timestamp: Date
        let type: ActivityType
        
        enum ActivityType {
            case saveFavoritePrimeTapped(Int)
            case removedFavoritePrime(Int)
        }
    }
    
    struct User {
        let id: Int
        let name: String
        let bio: String
    }
}

//MARK: - activity Feed
func activityFeed(
    _ reducer: @escaping (inout AppState, AppAction) -> Void
) -> (inout AppState, AppAction) -> Void {
    return { state, action in
        switch action {
        case .counterView(.counter):
            break

        case .counterView(.primeModal(.removeFavoritePrimeTapped)):
            state.activityFeed.append(
                .init(timestamp: Date(), type: .removedFavoritePrime(state.count))
            )

        case .counterView(.primeModal(.saveFavoritePrimeTapped)):
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
