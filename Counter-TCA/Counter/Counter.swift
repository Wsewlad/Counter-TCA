//
//  Counter.swift
//  Counter
//
//  Created by  Vladyslav Fil on 24.09.2022.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import OrderedCollections
import PrimeModal

let wolframAlphaApiKey = "T8R7LH-X7L2V6G98P"

//MARK: - Proxy Reducer
public let counterViewReducer = combine(
    pullback(counterReducer, state: \CounterViewState.counter, action: \CounterViewAction.counter),
    pullback(primeModalReducer, state: \.primeModal, action: \.primeModal)
)

//MARK: - Proxy Actions
public enum CounterViewAction {
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
public struct CounterViewState {
    public var count: Int
    public var favoritePrimes: OrderedSet<Int>
    public var alertNthPrime: Int?
    public var isNthPrimeButtonDisabled: Bool
    public var alertNthPrimePresented: Bool
    
    public init(
        count: Int,
        favoritePrimes: OrderedSet<Int>,
        alertNthPrime: Int?,
        isNthPrimeButtonDisabled: Bool,
        alertNthPrimePresented: Bool
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
public enum CounterAction {
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
            CounterView.nthPrime(n: state.count)
                .map(CounterAction.nthPrimeResponse)
                .receive(on: .main)
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

//MARK: - Wolfram Alpha
extension CounterView {
    static func wolframAlpha(query: String) -> Effect<WolframAlphaResult?> {
        var components = URLComponents(string: "https://api.wolframalpha.com/v2/query")!
        components.queryItems = [
            URLQueryItem(name: "input", value: query),
            URLQueryItem(name: "format", value: "plaintext"),
            URLQueryItem(name: "output", value: "JSON"),
            URLQueryItem(name: "appid", value: wolframAlphaApiKey)
        ]

        return dataTask(with: components.url(relativeTo: nil)!)
            .decode(as: WolframAlphaResult.self)
    }
    
    static func nthPrime(n: Int) -> Effect<Int?> {
        return wolframAlpha(query: "prime \(n)").map { result in
            result
                .flatMap {
                    $0.queryresult
                        .pods
                        .first(where: { $0.primary == .some(true) })?
                        .subpods
                        .first?
                        .plaintext
                }
                .flatMap(Int.init)
        }
    }
}

//MARK: - Models
struct WolframAlphaResult: Decodable {
    let queryresult: QueryResult
    
    struct QueryResult: Decodable {
        let pods: [Pod]
        
        struct Pod: Decodable {
            let primary: Bool?
            let subpods: [SubPod]
            
            struct SubPod: Decodable {
                let plaintext: String
            }
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
