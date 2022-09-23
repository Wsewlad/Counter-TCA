//
//  Counter_TCAApp.swift
//  Counter-TCA
//
//  Created by  Vladyslav Fil on 22.09.2022.
//

import SwiftUI

@main
struct Counter_TCAApp: App {
    @StateObject var store = Store(state: AppState(), reducer: appReducer)
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
        }
    }
}
