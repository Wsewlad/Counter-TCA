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
        return [
            Current.fileClient.save("favorite-primes.json", try! JSONEncoder().encode(state))
                .fireAndForget()
//                .map(absurd)
//                .eraseToEffect()
        ]
        
    case .loadButtonTapped:
        return [
            Current.fileClient.load("favorite-primes.json")
                .compactMap { $0 }
                .decode(type: [Int].self, decoder: JSONDecoder())
                .catch { error in Empty(completeImmediately: true) }
                .map(FavoritePrimesAction.loadedFavoritePrimes)
                .eraseToEffect()
        ]
    }
}

extension Publisher where Output == Never, Failure == Never {
    func fireAndForget<A>() -> Effect<A> {
        return self.map(absurd).eraseToEffect()
    }
}

func absurd<A>(_ never: Never) -> A {}

struct FileClient {
    var load: (String) -> Effect<Data?>
    var save: (String, Data) -> Effect<Never>
}

extension FileClient {
    static let live = FileClient(
        load: { fileName in
            .sync {
                let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let favoritePrimesUrl = documentsUrl.appendingPathComponent(fileName)
                return try? Data(contentsOf: favoritePrimesUrl)
            }
        },
        save: { fileName, data in
            .fireAndForget {
                let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let favoritePrimesUrl = documentsUrl.appendingPathComponent(fileName)
                try! data.write(to: favoritePrimesUrl)
            }
        }
    )
}

struct FavoritePrimesEnvironment {
    var fileClient: FileClient
}
extension FavoritePrimesEnvironment {
    static let live = FavoritePrimesEnvironment(fileClient: .live)
}

var Current = FavoritePrimesEnvironment.live

#if DEBUG
extension FavoritePrimesEnvironment {
    static let mock = FavoritePrimesEnvironment(
        fileClient: FileClient(
            load: { _ in Effect<Data?>.sync {
                try! JSONEncoder().encode([2, 31])
            } },
            save: { _, _ in .fireAndForget {} }
        )
    )
}
#endif

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
