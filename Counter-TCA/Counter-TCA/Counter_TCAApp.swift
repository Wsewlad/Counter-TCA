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

let _appReducer: Reducer<AppState, AppAction> = combine(
    pullback(counterViewReducer, state: \.counterView, action: \.counterView),
    pullback(favoritePrimesReducer, state: \.favoritePrimes, action: \.favoritePrimes)
)

let appReducer = pullback(_appReducer, state: \.self, action: \.self)

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
