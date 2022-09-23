//
//  Counter_TCAApp.swift
//  Counter-TCA
//
//  Created by  Vladyslav Fil on 22.09.2022.
//

import SwiftUI

let _appReducer = combine(
    transform(counterReducer, localValueKeyPath: \.count),
    primeModalReducer,
    transform(favoritePrimesReducer, localValueKeyPath: \.favoritePrimesState)
)

let appReducer = transform(_appReducer, localValueKeyPath: \.self)

@main
struct Counter_TCAApp: App {
    
    @StateObject var store = Store(
        state: AppState(),
        reducer: appReducer
    )
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
        }
    }
}
