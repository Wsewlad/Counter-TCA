//
//  AppAction.swift
//  Counter-TCA
//
//  Created by  Vladyslav Fil on 23.09.2022.
//

import Foundation
import FavoritePrimes
import Counter

enum AppAction {
    case counterView(CounterViewAction)
    case favoritePrimes(FavoritePrimesAction)
}

//MARK: - KeyPath access
extension AppAction {
    var counterView: CounterViewAction? {
        get {
            guard case let .counterView(value) = self else { return nil }
            return value
        }
        set {
            guard case .counterView = self, let newValue = newValue else { return }
            self = .counterView(newValue)
        }
    }
    
    var favoritePrimes: FavoritePrimesAction? {
        get {
            guard case let .favoritePrimes(value) = self else { return nil }
            return value
        }
        set {
            guard case .favoritePrimes = self, let newValue = newValue else { return }
            self = .favoritePrimes(newValue)
        }
    }
}
