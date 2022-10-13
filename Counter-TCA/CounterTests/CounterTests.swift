//
//  CounterTests.swift
//  CounterTests
//
//  Created by  Vladyslav Fil on 24.09.2022.
//

import XCTest
@testable import Counter

class CounterTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        Current = .mock
    }
    
    func testIncrTapped() throws {
       var state = CounterViewState(
            count: 2,
            favoritePrimes: [3, 5],
            alertNthPrime: nil,
            isNthPrimeButtonDisabled: false,
            alertNthPrimePresented: false
       )
        
        let effects = counterViewReducer(&state, .counter(.incrTapped))
        
        XCTAssertEqual(
            state,
            CounterViewState(
                 count: 3,
                 favoritePrimes: [3, 5],
                 alertNthPrime: nil,
                 isNthPrimeButtonDisabled: false,
                 alertNthPrimePresented: false
            )
        )
        
        XCTAssert(effects.isEmpty)
    }
    
    func testDecrTapped() throws {
       var state = CounterViewState(
            count: 2,
            favoritePrimes: [3, 5],
            alertNthPrime: nil,
            isNthPrimeButtonDisabled: false,
            alertNthPrimePresented: false
       )
        
        let effects = counterViewReducer(&state, .counter(.decrTapped))
        
        XCTAssertEqual(
            state,
            CounterViewState(
                 count: 1,
                 favoritePrimes: [3, 5],
                 alertNthPrime: nil,
                 isNthPrimeButtonDisabled: false,
                 alertNthPrimePresented: false
            )
        )
        
        XCTAssert(effects.isEmpty)
    }
    
    func testNthPrimeButtonHappyFlow() throws {
       var state = CounterViewState(
            count: 2,
            favoritePrimes: [3, 5],
            alertNthPrime: nil,
            isNthPrimeButtonDisabled: false,
            alertNthPrimePresented: false
       )
        
        var effects = counterViewReducer(&state, .counter(.nthPrimeButtonTapped))
        
        XCTAssertEqual(
            state,
            CounterViewState(
                 count: 2,
                 favoritePrimes: [3, 5],
                 alertNthPrime: nil,
                 isNthPrimeButtonDisabled: true,
                 alertNthPrimePresented: false
            )
        )
        XCTAssertEqual(effects.count, 1)
        
        effects = counterViewReducer(&state, .counter(.nthPrimeResponse(3)))
        
        XCTAssertEqual(
            state,
            CounterViewState(
                 count: 2,
                 favoritePrimes: [3, 5],
                 alertNthPrime: 3,
                 isNthPrimeButtonDisabled: false,
                 alertNthPrimePresented: true
            )
        )
        XCTAssert(effects.isEmpty)
        
        effects = counterViewReducer(&state, .counter(.updateBoolValue(\.alertNthPrimePresented, value: false)))
        XCTAssert(effects.isEmpty)
        effects = counterViewReducer(&state, .counter(.updateOptinalIntValue(\.alertNthPrime, value: nil)))
        XCTAssertEqual(
            state,
            CounterViewState(
                 count: 2,
                 favoritePrimes: [3, 5],
                 alertNthPrime: nil,
                 isNthPrimeButtonDisabled: false,
                 alertNthPrimePresented: false
            )
        )
        XCTAssert(effects.isEmpty)
    }
    
    func testNthPrimeButtonUnhappyFlow() throws {
       var state = CounterViewState(
            count: 2,
            favoritePrimes: [3, 5],
            alertNthPrime: nil,
            isNthPrimeButtonDisabled: false,
            alertNthPrimePresented: false
       )
        
        var effects = counterViewReducer(&state, .counter(.nthPrimeButtonTapped))
        
        XCTAssertEqual(
            state,
            CounterViewState(
                 count: 2,
                 favoritePrimes: [3, 5],
                 alertNthPrime: nil,
                 isNthPrimeButtonDisabled: true,
                 alertNthPrimePresented: false
            )
        )
        XCTAssertEqual(effects.count, 1)
        
        effects = counterViewReducer(&state, .counter(.nthPrimeResponse(nil)))
        
        XCTAssertEqual(
            state,
            CounterViewState(
                 count: 2,
                 favoritePrimes: [3, 5],
                 alertNthPrime: nil,
                 isNthPrimeButtonDisabled: false,
                 alertNthPrimePresented: false
            )
        )
        XCTAssert(effects.isEmpty)
    }
    
    func testPrimeModal() throws {
       var state = CounterViewState(
            count: 2,
            favoritePrimes: [3, 5],
            alertNthPrime: nil,
            isNthPrimeButtonDisabled: false,
            alertNthPrimePresented: false
       )
        
        var effects = counterViewReducer(&state, .primeModal(.saveFavoritePrimeTapped))
        XCTAssertEqual(
            state,
            CounterViewState(
                 count: 2,
                 favoritePrimes: [3, 5, 2],
                 alertNthPrime: nil,
                 isNthPrimeButtonDisabled: false,
                 alertNthPrimePresented: false
            )
        )
        XCTAssert(effects.isEmpty)
        
        effects = counterViewReducer(&state, .primeModal(.removeFavoritePrimeTapped))
        XCTAssertEqual(
            state,
            CounterViewState(
                 count: 2,
                 favoritePrimes: [3, 5],
                 alertNthPrime: nil,
                 isNthPrimeButtonDisabled: false,
                 alertNthPrimePresented: false
            )
        )
        XCTAssert(effects.isEmpty)
    }
}
