//
//  FavoritePrimesTests.swift
//  FavoritePrimesTests
//
//  Created by  Vladyslav Fil on 24.09.2022.
//

import XCTest
@testable import FavoritePrimes

class FavoritePrimesTests: XCTestCase {

    func testDeleteFavoritePrimes() throws {
        var state = [3, 5, 7]
        let effects = favoritePrimesReducer(state: &state, action: .deleteFavoritePrimes([0]))
        
        XCTAssertEqual(state, [5, 7])
        XCTAssert(effects.isEmpty)
    }
    
    func testSaveButtonTapped() throws {
        var state = [3, 5, 7]
        let effects = favoritePrimesReducer(state: &state, action: .saveButtonTapped)
        
        XCTAssertEqual(state, [3, 5, 7])
        XCTAssertEqual(effects.count, 1)
    }
    
    func testLoadFavoritePrimesFlow() throws {
        var state = [3, 5, 7]
        var effects = favoritePrimesReducer(state: &state, action: .loadButtonTapped)
        
        XCTAssertEqual(state, [3, 5, 7])
        XCTAssertEqual(effects.count, 1)
        
        effects = favoritePrimesReducer(state: &state, action: .loadedFavoritePrimes([2, 31]))
        
        XCTAssertEqual(state, [2, 31])
        XCTAssert(effects.isEmpty)
    }
}
