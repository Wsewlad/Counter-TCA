//
//  Int.swift
//  Counter-TCA
//
//  Created by  Vladyslav Fil on 22.09.2022.
//

import Foundation

//MARK: - ordinal
extension Int {
    var ordinal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle  = .ordinal
        return formatter.string(for: self) ?? "\(self)"
    }
}

//MARK: - Is Prime
extension Int {
    var isPrime: Bool {
        if self <= 1 { return false }
        if self <= 3 { return true }
        for i in 2...Int(sqrt(Float(self))) {
            if self % i == 0 { return false }
        }
        return true
    }
}
