import SwiftUI
import PlaygroundSupport
import OrderedCollections
import ComposableArchitecture
import FavoritePrimes

PlaygroundPage.current.setLiveView(
    NavigationView {
        FavoritePrimesView(
            store: Store<OrderedSet<Int>, FavoritePrimesAction>(
                state: [1, 2, 3],
                reducer: favoritePrimesReducer
            )
        )
    }
)
