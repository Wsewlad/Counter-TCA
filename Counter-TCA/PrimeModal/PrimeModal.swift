//
//  PrimeModal.swift
//  PrimeModal
//
//  Created by  Vladyslav Fil on 24.09.2022.
//

import Foundation
import Collections
import SwiftUI
import ComposableArchitecture

public typealias PrimeModalState = (count: Int, favoritePrimes: OrderedSet<Int>)

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

public struct IfPrimeModalView: View {
    @ObservedObject var store: Store<PrimeModalState, PrimeModalAction>
    
    public init(store: Store<PrimeModalState, PrimeModalAction>) {
        self.store = store
    }
    
    public var body: some View {
        VStack {
            Text(title)
            if self.store.state.count.isPrime {
                Button(action: { toggleFavorites() }) {
                    Text(actionTitle)
                }
            }
        }
    }
}

//MARK: - Actions
private extension IfPrimeModalView {
    func toggleFavorites() {
        if isInFavorites {
            self.store.send(.removeFavoritePrimeTapped)
        } else {
            self.store.send(.saveFavoritePrimeTapped)
        }
    }
    
    var isInFavorites: Bool {
        self.store.state.favoritePrimes.contains(self.store.state.count)
    }
}

//MARK: - Computed Properties
private extension IfPrimeModalView {
    var title: String {
        self.store.state.count.isPrime ?
        "\(self.store.state.count) is prime 🎉" :
        "\(self.store.state.count) is not prime :("
    }
    
    var actionTitle: String {
        isInFavorites ?
        "Remove from favorite primes" :
        "Save to favorite primes"
    }
}

extension Int {
    var isPrime: Bool {
        if self <= 1 { return false }
        if self <= 3 { return true }
        for i in 2...Int(sqrt(Float(self))) {
            if self % i == 0 { return false }
        }
        return true
    }
}
