//
//  RootView.swift
//  Counter-TCA
//
//  Created by  Vladyslav Fil on 22.09.2022.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
    @EnvironmentObject var store: Store<AppState, AppAction>
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(
                    "Counter demo",
                    destination: CounterView()
                        .environmentObject(store.view { ($0.count, $0.favoritePrimes) })
                )
                NavigationLink(
                    "Favorite primes",
                    destination: FavoritePrimesView()
                        .environmentObject(store.view { $0.favoritePrimes })
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
