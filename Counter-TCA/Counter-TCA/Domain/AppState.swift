//
//  Model.swift
//  Counter-TCA
//
//  Created by  Vladyslav Fil on 22.09.2022.
//

import Foundation
import SwiftUI
import Counter
import ComposableArchitecture

struct AppState {
    var count: Int = 0
    var favoritePrimes: [Int] = []
    var loggedInUser: User? = nil
    var activityFeed: [Activity] = []
    
    var alertNthPrime: Int? = nil
    var isNthPrimeButtonDisabled: Bool = false
    var alertNthPrimePresented: Bool = false
}

//MARK: - KeyPath
extension AppState {
    var counterView: CounterViewState {
        get {
            CounterViewState(
                count: self.count,
                favoritePrimes: self.favoritePrimes,
                alertNthPrime: self.alertNthPrime,
                isNthPrimeButtonDisabled: self.isNthPrimeButtonDisabled,
                alertNthPrimePresented: self.alertNthPrimePresented
            )
        }
        set {
            self.count = newValue.count
            self.favoritePrimes = newValue.favoritePrimes
            self.alertNthPrime = newValue.alertNthPrime
            self.isNthPrimeButtonDisabled = newValue.isNthPrimeButtonDisabled
            self.alertNthPrimePresented = newValue.alertNthPrimePresented
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
    _ reducer: @escaping Reducer<AppState, AppAction>
) -> Reducer<AppState, AppAction> {
    return { state, action in
        switch action {
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
            
        default:
            break
        }
        
        return reducer(&state, action)
    }
}
