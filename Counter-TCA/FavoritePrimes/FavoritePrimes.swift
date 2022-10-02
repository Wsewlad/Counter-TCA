//
//  FavoritePrimes.swift
//  FavoritePrimes
//
//  Created by  Vladyslav Fil on 24.09.2022.
//

import Foundation
import SwiftUI
import OrderedCollections
import ComposableArchitecture

//MARK: - Actions
public enum FavoritePrimesAction {
    case deleteFavoritePrimes(IndexSet)
}

//MARK: - Reducer
public func favoritePrimesReducer(state: inout OrderedSet<Int>, action: FavoritePrimesAction) {
    switch action {
    case .deleteFavoritePrimes(let indexSet):
        for index in indexSet {
            state.remove(at: index)
        }
    }
}

//MARK: - View
public struct FavoritePrimesView: View {
    @ObservedObject var store: Store<OrderedSet<Int>, FavoritePrimesAction>
    
    public init(store: Store<OrderedSet<Int>, FavoritePrimesAction>) {
        self.store = store
    }
    
    public var body: some View {
        List {
            ForEach(self.store.state, id: \.self) { prime in
                Text("\(prime)")
            }
            .onDelete { self.store.send(.deleteFavoritePrimes($0)) }
        }
        .navigationTitle("Favorite Primes")
    }
}
