//
//  FavoritePrimesView.swift
//  Counter-TCA
//
//  Created by  Vladyslav Fil on 23.09.2022.
//

import SwiftUI
import ComposableArchitecture
import Collections

struct FavoritePrimesView: View {
    @EnvironmentObject var store: Store<OrderedSet<Int>, AppAction>
    
    var body: some View {
        List {
            ForEach(self.store.state, id: \.self) { prime in
                Text("\(prime)")
            }
            .onDelete { self.store.send(.favoritePrimes(.deleteFavoritePrimes($0))) }
        }
        .navigationTitle("Favorite Primes")
    }
}

struct FavoritePrimesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritePrimesView()
    }
}
