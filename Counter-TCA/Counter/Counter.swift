//
//  Counter.swift
//  Counter
//
//  Created by  Vladyslav Fil on 24.09.2022.
//

import Foundation

public enum CounterAction {
    case decrTapped
    case incrTapped
}

public func counterReducer(state: inout Int, action: CounterAction) {
    switch action {
    case .decrTapped:
        state -= 1
    case .incrTapped:
        state += 1
    }
}
