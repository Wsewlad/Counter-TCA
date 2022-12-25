//
//  CounterTests.swift
//  CounterTests
//
//  Created by  Vladyslav Fil on 24.09.2022.
//

import XCTest
@testable import Counter
import ComposableArchitecture

class CounterTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        Current = .mock
    }
    
    func testIncrDecrTapped() throws {
        assert(
            initialValue: CounterViewState(count: 2),
            reducer: counterViewReducer,
            steps:
            Step(.send, .counter(.incrTapped)) { $0.count = 3 },
            Step(.send, .counter(.incrTapped)) { $0.count = 4 },
            Step(.send, .counter(.decrTapped)) { $0.count = 3 }
        )
    }
    
    func testNthPrimeButtonHappyFlow() throws {
        Current.nthPrime = { _ in .sync { 17 }}
        
        assert(
            initialValue: CounterViewState(
                alertNthPrime: nil,
                isNthPrimeButtonDisabled: false,
                alertNthPrimePresented: false
            ),
            reducer: counterViewReducer,
            steps:
            Step(.send, .counter(.nthPrimeButtonTapped)) {
                $0.isNthPrimeButtonDisabled = true
            },
            Step(.receive, .counter(.nthPrimeResponse(17))) {
                $0.isNthPrimeButtonDisabled = false
                $0.alertNthPrime = 17
                $0.alertNthPrimePresented = true
            },
            Step(.send, .counter(.updateBoolValue(\.alertNthPrimePresented, value: false))) {
                $0.alertNthPrimePresented = false
            },
            Step(.send, .counter(.updateOptinalIntValue(\.alertNthPrime, value: nil))) {
                $0.alertNthPrime = nil
            }
        )
    }
    
    func testNthPrimeButtonUnhappyFlow() throws {
        Current.nthPrime = { _ in .sync { nil }}
        
        assert(
            initialValue: CounterViewState(
                isNthPrimeButtonDisabled: false
           ),
            reducer: counterViewReducer,
            steps:
            Step(.send, .counter(.nthPrimeButtonTapped)) {
                $0.isNthPrimeButtonDisabled = true
            },
            Step(.receive, .counter(.nthPrimeResponse(nil))) {
                $0.isNthPrimeButtonDisabled = false
            }
        )
    }
    
    func testPrimeModal() throws {
        assert(
            initialValue: CounterViewState(
                count: 2,
                favoritePrimes: [3, 5]
           ),
            reducer: counterViewReducer,
            steps:
            Step(.send, .primeModal(.saveFavoritePrimeTapped)) {
                $0.favoritePrimes = [3, 5, 2]
            },
            Step(.send, .primeModal(.removeFavoritePrimeTapped)) {
                $0.favoritePrimes = [3, 5]
            }
        )
    }
}
