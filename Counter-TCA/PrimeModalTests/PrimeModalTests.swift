//
//  PrimeModalTests.swift
//  PrimeModalTests
//
//  Created by  Vladyslav Fil on 24.09.2022.
//

import XCTest
@testable import PrimeModal

class PrimeModalTests: XCTestCase {
    func testSaveFavoritePrimeTapped() throws {
        var state = (count: 2, favoritePrimes: [3, 5])
        let effects = primeModalReducer(state: &state, action: .saveFavoritePrimeTapped)
        
        let (count, favoritePrimes) = state
        XCTAssertEqual(count, 2)
        XCTAssertEqual(favoritePrimes, [3, 5, 2])
        XCTAssert(effects.isEmpty)
    }
    
    func testRemoveFavoritePrimeTapped() throws {
        var state = (count: 5, favoritePrimes: [3, 5])
        let effects = primeModalReducer(state: &state, action: .removeFavoritePrimeTapped)
        
        let (count, favoritePrimes) = state
        XCTAssertEqual(count, 5)
        XCTAssertEqual(favoritePrimes, [3])
        XCTAssert(effects.isEmpty)
    }
}
