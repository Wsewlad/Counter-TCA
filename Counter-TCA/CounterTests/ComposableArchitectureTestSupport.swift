//
//  ComposableArchitectureTestSupport.swift
//  CounterTests
//
//  Created by  Vladyslav Fil on 25.12.2022.
//

import ComposableArchitecture
import Combine
import XCTest

enum StepType {
    case send
    case receive
}

struct Step<Value, Action> {
    let type: StepType
    let action: Action
    let update: (inout Value) -> Void
    let file: StaticString
    let line: UInt
    
    init(
        file: StaticString = #file,
        line: UInt = #line,
        _ type: StepType,
        _ action: Action,
        _ update: @escaping (inout Value) -> Void
    ) {
        self.file = file
        self.line = line
        self.type = type
        self.action = action
        self.update = update
    }
}

func assert<Value: Equatable, Action: Equatable>(
    initialValue: Value,
    reducer: Reducer<Value, Action>,
    steps: Step<Value, Action>...,
    file: StaticString = #file,
    line: UInt = #line
) {
    var state = initialValue
    var effects: [Effect<Action>] = []
    var cancellables: [AnyCancellable] = []
    
    steps.forEach { step in
        var expected = state
        
        switch step.type {
        case .send:
            if !effects.isEmpty {
                XCTFail("Action sent before handling \(effects.count) pending effect(s)", file: step.file, line: step.line)
            }
            effects.append(contentsOf: reducer(&state, step.action))
            
        case .receive:
            guard !effects.isEmpty else {
                XCTFail("No pending effects to receive from", file: step.file, line: step.line)
                break
            }
            let effect = effects.removeFirst()
            var action: Action!
            let receivedCompletion = XCTestExpectation(description: "receivedCompletion")
            cancellables.append(
                effect.sink(
                    receiveCompletion: { _ in
                        receivedCompletion.fulfill()
                    }, receiveValue: {
                        action = $0
                    }
                )
            )
            if XCTWaiter.wait(for: [receivedCompletion], timeout: 0.01) != .completed {
                XCTFail("Timed out waiting for effect to complete", file: step.file, line: step.line)
            }
            XCTAssertEqual(action, step.action, file: step.file, line: step.line)
            effects.append(contentsOf: reducer(&state, action))
        }
        
        step.update(&expected)
        XCTAssertEqual(state, expected, file: step.file, line: step.line)
    }
    
    if !effects.isEmpty {
        XCTFail("Assertion failed to handle \(effects.count) pending effect(s)", file: file, line: line)
    }
}
