//
//  Counter_TCAApp.swift
//  Counter-TCA
//
//  Created by  Vladyslav Fil on 22.09.2022.
//

import SwiftUI

@main
struct Counter_TCAApp: App {
    @StateObject var model = Model()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(model)
        }
    }
}
