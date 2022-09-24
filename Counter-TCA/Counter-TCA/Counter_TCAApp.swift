//
//  Counter_TCAApp.swift
//  Counter-TCA
//
//  Created by  Vladyslav Fil on 22.09.2022.
//

import SwiftUI

let _appReducer: (inout AppState, AppAction) -> Void = combine(
    transform(counterReducer, state: \.count, action: \.counter),
    transform(primeModalReducer, state: \.self, action: \.primeModal),
    transform(favoritePrimesReducer, state: \.favoritePrimesState.favoritePrimes, action: \.favoritePrimes)
)

let appReducer = transform(_appReducer, state: \.self, action: \.self)

@main
struct Counter_TCAApp: App {
    
    @StateObject var store = Store(
        state: AppState(),
        reducer: logging(activityFeed(appReducer))
    )
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
        }
    }
}
