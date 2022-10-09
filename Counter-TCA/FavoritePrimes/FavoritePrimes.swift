//
//  FavoritePrimes.swift
//  FavoritePrimes
//
//  Created by  Vladyslav Fil on 24.09.2022.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import Combine

//MARK: - Actions
public enum FavoritePrimesAction {
    case deleteFavoritePrimes(IndexSet)
    case loadedFavoritePrimes([Int])
    case saveButtonTapped
    case loadButtonTapped
}

//MARK: - Reducer
public func favoritePrimesReducer(state: inout [Int], action: FavoritePrimesAction) -> [Effect<FavoritePrimesAction>] {
    switch action {
    case .deleteFavoritePrimes(let indexSet):
        for index in indexSet {
            state.remove(at: index)
        }
        return []
        
    case let .loadedFavoritePrimes(primes):
        state = primes
        return []
        
    case .saveButtonTapped:
        return [ saveEffect(favoritePrimes: state) ]
        
    case .loadButtonTapped:
        return [
            loadEffect
                .compactMap { $0 }
                .eraseToEffect()
        ]
    }
}

//MARK: - Effects
private func saveEffect(favoritePrimes: [Int]) -> Effect<FavoritePrimesAction> {
    return .fireAndForget {
        let data = try! JSONEncoder().encode(favoritePrimes)
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let favoritePrimesUrl = documentsUrl.appendingPathComponent("favorite-primes.json")
        try! data.write(to: favoritePrimesUrl)
    }
}

private let loadEffect = Effect<FavoritePrimesAction?>.sync {
    let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let favoritePrimesUrl = documentsUrl.appendingPathComponent("favorite-primes.json")
    guard
        let data = try? Data(contentsOf: favoritePrimesUrl),
        let favoritePrimes = try? JSONDecoder().decode([Int].self, from: data)
    else { return nil }
    return .loadedFavoritePrimes(favoritePrimes)
}

//MARK: - View
public struct FavoritePrimesView: View {
    @ObservedObject var store: Store<[Int], FavoritePrimesAction>
    
    public init(store: Store<[Int], FavoritePrimesAction>) {
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button("Save") {
                        self.store.send(.saveButtonTapped)
                    }
                    Button("Load") {
                        self.store.send(.loadButtonTapped)
                    }
                }
            }
        }
    }
}
