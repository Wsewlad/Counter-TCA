import Foundation
import SwiftUI
import PlaygroundSupport
import OrderedCollections
import ComposableArchitecture
import FavoritePrimes
import PrimeModal
import Counter

PlaygroundPage.current.liveView = UIHostingController(
    rootView: CounterView(
        store: Store<CounterViewState, CounterViewAction>(
            state: (0, []),
            reducer: counterViewReducer
        )
    )
)

//PlaygroundPage.current.liveView = UIHostingController(
//    rootView: IfPrimeModalView(
//        store: Store<PrimeModalState, PrimeModalAction>(
//            state: (3, []),
//            reducer: primeModalReducer
//        )
//    )
//)

//PlaygroundPage.current.liveView = UIHostingController(
//    rootView: FavoritePrimesView(
//        store: Store<OrderedSet<Int>, FavoritePrimesAction>(
//            state: [1, 2, 3],
//            reducer: favoritePrimesReducer
//        )
//    )
//)


//let store = Store<Int,()>(state: 0, reducer: { count, _ in count += 1 })
//
//store.send(())
//store.send(())
//store.send(())
//store.send(())
//store.send(())
//
//store.state
//
//let newStore = store.view { $0 }
//
//newStore.state
//
//newStore.send(())
//newStore.send(())
//newStore.send(())
//newStore.send(())
//newStore.send(())
//
//newStore.state
//
//store.state
//
//store.send(())
//store.send(())
//
//store.state
//newStore.state

