//
//  FavoritePrimesTests.swift
//  FavoritePrimesTests
//
//  Created by  Vladyslav Fil on 24.09.2022.
//

import XCTest
@testable import FavoritePrimes

class FavoritePrimesTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        Current = .mock
    }

    func testDeleteFavoritePrimes() throws {
        var state = [3, 5, 7]
        let effects = favoritePrimesReducer(state: &state, action: .deleteFavoritePrimes([0]))
        
        XCTAssertEqual(state, [5, 7])
        XCTAssert(effects.isEmpty)
    }
    
    func testSaveButtonTapped() throws {
        var didSave = false
        Current.fileClient.save = { _, _ in
            .fireAndForget {
                didSave = true
            }
        }
        
        var state = [3, 5, 7]
        let effects = favoritePrimesReducer(state: &state, action: .saveButtonTapped)
        
        XCTAssertEqual(state, [3, 5, 7])
        XCTAssertEqual(effects.count, 1)
        
        effects[0].sink { _ in XCTFail() }
        XCTAssert(didSave)
    }
    
    func testLoadFavoritePrimesFlow() throws {
        Current.fileClient.load = { _ in
            .sync {
                try! JSONEncoder().encode([2, 31])
            }
        }
        
        var state = [3, 5, 7]
        var effects = favoritePrimesReducer(state: &state, action: .loadButtonTapped)
        
        XCTAssertEqual(state, [3, 5, 7])
        XCTAssertEqual(effects.count, 1)
        
        var nextAction: FavoritePrimesAction!
        let receivedCompletion = self.expectation(description: "receivedCompletion")
        effects[0].sink(
            receiveCompletion: { _ in
                receivedCompletion.fulfill()
            },
            receiveValue: { action in
                XCTAssertEqual(action, .loadedFavoritePrimes([2, 31]))
                nextAction = action
            }
        )
        self.wait(for: [receivedCompletion], timeout: 0)
        
        effects = favoritePrimesReducer(state: &state, action: nextAction)
        
        XCTAssertEqual(state, [2, 31])
        XCTAssert(effects.isEmpty)
    }
}
