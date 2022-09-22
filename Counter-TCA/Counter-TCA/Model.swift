//
//  Model.swift
//  Counter-TCA
//
//  Created by  Vladyslav Fil on 22.09.2022.
//

import Foundation
import SwiftUI

@MainActor
final class Model: ObservableObject {
    @Published var count: Int = 0
    @Published var favoritePrimes: Set<Int> = []
    
    
}

//MARK: - Favorites
extension Model {
    var isInFavorites: Bool {
        favoritePrimes.contains(self.count)
    }
    
    func toggleFavorites() {
        if isInFavorites {
            favoritePrimes.remove(self.count)
        } else {
            favoritePrimes.insert(self.count)
        }
    }
}

//MARK: - Counter
extension Model {
    func increment() {
        count += 1
    }
    
    func decrement() {
        guard count >= 1 else { return }
        count -= 1
    }
}
