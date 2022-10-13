import SwiftUI
import PlaygroundSupport
import ComposableArchitecture
@testable import FavoritePrimes

Current = .mock
Current.fileClient.load = { _ in
    .sync {
        try! JSONEncoder().encode(Array(1...100))
    }
}

PlaygroundPage.current.setLiveView(
    NavigationView {
        FavoritePrimesView(
            store: Store<[Int], FavoritePrimesAction>(
                state: [1, 2, 3],
                reducer: favoritePrimesReducer
            )
        )
    }
)
