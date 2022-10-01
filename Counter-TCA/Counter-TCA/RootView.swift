//
//  RootView.swift
//  Counter-TCA
//
//  Created by  Vladyslav Fil on 22.09.2022.
//

import SwiftUI
import ComposableArchitecture
import FavoritePrimes
import Counter

struct RootView: View {
    @EnvironmentObject var store: Store<AppState, AppAction>
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(
                    "Counter demo",
                    destination: CounterView(
                        store: store.view(
                            state: { ($0.count, $0.favoritePrimes) },
                            action: {
                                switch $0 {
                                case let .counter(action):
                                    return .counter(action)
                                case let .primeModal(action):
                                    return .primeModal(action)
                                }
                            }
                        )
                    )
                )
                NavigationLink(
                    "Favorite primes",
                    destination: FavoritePrimesView(
                        store: store.view(
                            state: { $0.favoritePrimes },
                            action: { .favoritePrimes($0) }
                        )
                    )
                )
            }
            .navigationTitle("State management")
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
