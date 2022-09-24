//
//  Activity.swift
//  Counter-TCA
//
//  Created by  Vladyslav Fil on 23.09.2022.
//

import Foundation

struct Activity {
    let timestamp: Date
    let type: ActivityType
    
    enum ActivityType {
        case saveFavoritePrimeTapped(Int)
        case removedFavoritePrime(Int)
    }
}
