//
//  FavoritePrimesView.swift
//  Counter-TCA
//
//  Created by  Vladyslav Fil on 23.09.2022.
//

import SwiftUI

struct FavoritePrimesView: View {
    @EnvironmentObject var model: Model
    
    var body: some View {
        List {
            ForEach(model.favoritePrimes, id: \.self) { prime in
                Text("\(prime)")
            }
            .onDelete { model.removeFromFavorites(at: $0) } 
        }
        .navigationTitle("Favorite Primes")
    }
}

struct FavoritePrimesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritePrimesView()
    }
}
