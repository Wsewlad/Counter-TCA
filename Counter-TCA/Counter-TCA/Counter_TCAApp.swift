//
//  Counter_TCAApp.swift
//  Counter-TCA
//
//  Created by  Vladyslav Fil on 22.09.2022.
//

import SwiftUI
import Overture
import ComposableArchitecture
import FavoritePrimes
import Counter
import PrimeModal

let _appReducer: (inout AppState, AppAction) -> Void = combine(
    transform(counterReducer, state: \.count, action: \.counter),
    transform(primeModalReducer, state: \.primeModal, action: \.primeModal),
    transform(favoritePrimesReducer, state: \.favoritePrimes, action: \.favoritePrimes)
)

let appReducer = transform(_appReducer, state: \.self, action: \.self)

@main
struct Counter_TCAApp: App {
    
    @StateObject var store = Store(
        state: AppState(),
        reducer: with(
            appReducer,
            compose(
                logging,
                activityFeed
            )
        )
    )
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
        }
    }
}
