//
//  Counter.swift
//  Counter
//
//  Created by  Vladyslav Fil on 24.09.2022.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import PrimeModal

//MARK: - Proxy Reducer
public let counterViewReducer = combine(
    pullback(counterReducer, state: \CounterViewState.counter, action: \CounterViewAction.counter),
    pullback(primeModalReducer, state: \.primeModal, action: \.primeModal)
)

//MARK: - Proxy Actions
public enum CounterViewAction: Equatable {
    case counter(CounterAction)
    case primeModal(PrimeModalAction)
}

//MARK: - Proxy Actions KeyPath
public extension CounterViewAction {
    var counter: CounterAction? {
        get {
            guard case let .counter(value) = self else { return nil }
            return value
        }
        set {
            guard case .counter = self, let newValue = newValue else { return }
            self = .counter(newValue)
        }
    }
    
    var primeModal: PrimeModalAction? {
        get {
            guard case let .primeModal(value) = self else { return nil }
            return value
        }
        set {
            guard case .primeModal = self, let newValue = newValue else { return }
            self = .primeModal(newValue)
        }
    }
}

//MARK: - State
public struct CounterViewState: Equatable {
    public var count: Int
    public var favoritePrimes: [Int]
    public var alertNthPrime: Int?
    public var isNthPrimeButtonDisabled: Bool
    public var alertNthPrimePresented: Bool
    
    public init(
        count: Int = 0,
        favoritePrimes: [Int] = [],
        alertNthPrime: Int? = nil,
        isNthPrimeButtonDisabled: Bool = false,
        alertNthPrimePresented: Bool = false
    ) {
        self.count = count
        self.favoritePrimes = favoritePrimes
        self.alertNthPrime = alertNthPrime
        self.isNthPrimeButtonDisabled = isNthPrimeButtonDisabled
        self.alertNthPrimePresented = alertNthPrimePresented
    }
    
    var counter: CounterState {
        get { (self.alertNthPrime, self.count, self.isNthPrimeButtonDisabled, self.alertNthPrimePresented) }
        set { (self.alertNthPrime, self.count, self.isNthPrimeButtonDisabled, self.alertNthPrimePresented) = newValue }
    }
    
    var primeModal: PrimeModalState {
        get { (self.count, self.favoritePrimes) }
        set { (self.count, self.favoritePrimes) = newValue }
    }
}

//MARK: - Actions
public enum CounterAction: Equatable {
    case decrTapped
    case incrTapped
    case nthPrimeButtonTapped
    case nthPrimeResponse(Int?)
    case updateOptinalIntValue(WritableKeyPath<CounterState, Int?>, value: Int?)
    case updateBoolValue(WritableKeyPath<CounterState, Bool>, value: Bool)
}

public typealias CounterState = (
    alertNthPrime: Int?,
    count: Int,
    isNthPrimeButtonDisabled: Bool,
    alertNthPrimePresented: Bool
)

//MARK: - Reducer
public func counterReducer(state: inout CounterState, action: CounterAction) -> [Effect<CounterAction>] {
    switch action {
    case .decrTapped:
        state.count -= 1
        return []
        
    case .incrTapped:
        state.count += 1
        return []
        
    case .nthPrimeButtonTapped:
        state.isNthPrimeButtonDisabled = true
        return [
            Current.nthPrime(state.count)
                .map(CounterAction.nthPrimeResponse)
                .receive(on: DispatchQueue.main)
                .eraseToEffect()
        ]
        
    case let .nthPrimeResponse(prime):
        state.alertNthPrime = prime
        state.alertNthPrimePresented = prime != nil
        state.isNthPrimeButtonDisabled = false
        return []
        
    case let .updateOptinalIntValue(keyPath, value):
        state[keyPath: keyPath] = value
        return []
        
    case let .updateBoolValue(keyPath, value):
        state[keyPath: keyPath] = value
        return []
    }
}

struct CounterEnvironment {
    var nthPrime: (Int) -> Effect<Int?>
}

extension CounterEnvironment {
    static let live = CounterEnvironment(nthPrime: Counter.nthPrime)
}

var Current = CounterEnvironment.live

extension CounterEnvironment {
    static let mock = CounterEnvironment(nthPrime: { _ in .sync { 17 } })
}

//MARK: - View
public struct CounterView: View {
    @ObservedObject var store: Store<CounterViewState, CounterViewAction>
    
    @State private var isPrimeModalShown: Bool = false
    
    public init(store: Store<CounterViewState, CounterViewAction>) {
        self.store = store
    }
    
    public var body: some View {
        VStack {
            stepperView
                .alert(
                    "",
                    isPresented: .init(
                        get: { self.store.state.alertNthPrimePresented },
                        set: { self.store.send(.counter(.updateBoolValue(\.alertNthPrimePresented, value: $0))) }
                    ),
                    presenting: self.store.state.alertNthPrime,
                    actions: { _ in Button("OK") {  } },
                    message: { n in Text("The \(self.store.state.count.ordinal) prime is \(n)") }
                )
                .onChange(of: self.store.state.alertNthPrimePresented) { newValue in
                    if !newValue {
                        self.store.send(.counter(.updateOptinalIntValue(\.alertNthPrime, value: nil)))
                    }
                }
            
            buttonsView
        }
        .font(.title)
        .navigationTitle("Counter demo")
        .sheet(isPresented: $isPrimeModalShown) {
            IfPrimeModalView(
                store: store.view(
                    state: { ($0.count, $0.favoritePrimes) },
                    action: { .primeModal($0) }
                )
            )
        }
    }
}

//MARK: - Stepper View
private extension CounterView {
    var stepperView: some View {
        HStack {
            Button("-") { self.store.send(.counter(.decrTapped)) }
            
            Text("\(self.store.state.count)")
            
            Button("+") { self.store.send(.counter(.incrTapped)) }
        }
    }
}

//MARK: - Buttons View
private extension CounterView {
    var buttonsView: some View {
        VStack {
            Button(action: { self.isPrimeModalShown.toggle() }) {
                Text("Is this prime?")
            }
            
            Button(action: { self.store.send(.counter(.nthPrimeButtonTapped)) }) {
                Text("What is the \(self.store.state.count.ordinal) prime?")
            }
            .disabled(self.store.state.isNthPrimeButtonDisabled)
        }
    }
}

//MARK: - Helpers
extension Int {
    var ordinal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle  = .ordinal
        return formatter.string(for: self) ?? ""
    }
}
