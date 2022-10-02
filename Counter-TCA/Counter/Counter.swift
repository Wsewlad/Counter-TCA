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
    pullback(counterReducer, state: \CounterViewState.count, action: \CounterViewAction.counter),
    pullback(primeModalReducer, state: \.self, action: \.primeModal)
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
public typealias CounterViewState = (count: Int, favoritePrimes: OrderedSet<Int>)

//MARK: - Actions
public enum CounterAction {
    case decrTapped
    case incrTapped
}

//MARK: - Reducer
public func counterReducer(state: inout Int, action: CounterAction) {
    switch action {
    case .decrTapped:
        state -= 1
    case .incrTapped:
        state += 1
    }
}

//MARK: - View
public struct CounterView: View {
    @ObservedObject var store: Store<CounterViewState, CounterViewAction>
    
    @State private var isPrimeModalShown: Bool = false
    @State private var alertNthPrimePresented: Bool = false
    @State private var alertNthPrime: Int?  = nil
    @State private var isNthPrimeButtonDisabled: Bool = false
    
    public init(store: Store<CounterViewState, CounterViewAction>) {
        self.store = store
    }
    
    public var body: some View {
        VStack {
            stepperView
                .alert(
                    "",
                    isPresented: $alertNthPrimePresented,
                    presenting: alertNthPrime,
                    actions: { _ in Button("OK", action: {}) },
                    message: { n in Text("The \(self.store.state.count.ordinal) prime is \(n)") }
                )
                .onChange(of: alertNthPrimePresented) { newValue in
                    if !newValue {
                        alertNthPrime = nil
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
            
            Button(action: self.nthPrimeButtonAction) {
                Text("What is the \(self.store.state.count.ordinal) prime?")
            }
            .disabled(self.isNthPrimeButtonDisabled)
        }
    }
}

//MARK: - Functions
private extension CounterView {
    func nthPrimeButtonAction() {
        self.isNthPrimeButtonDisabled = true
        self.nthPrime {
            self.alertNthPrime = $0
            self.alertNthPrimePresented = $0 != nil
            self.isNthPrimeButtonDisabled = false
        }
    }
}

//MARK: - Wolfram Alpha
extension CounterView {
    func wolframAlpha(query: String, callback: @escaping (WolframAlphaResult?) -> Void) -> Void {
        var components = URLComponents(string: "https://api.wolframalpha.com/v2/query")!
        components.queryItems = [
            URLQueryItem(name: "input", value: query),
            URLQueryItem(name: "format", value: "plaintext"),
            URLQueryItem(name: "output", value: "JSON"),
            URLQueryItem(name: "appid", value: wolframAlphaApiKey)
        ]

        URLSession.shared.dataTask(with: components.url(relativeTo: nil)!) { data, response, error in
            callback(
                data
                    .flatMap { try? JSONDecoder().decode(WolframAlphaResult.self, from: $0) }
            )
        }
        .resume()
    }
    
    func nthPrime(callback: @escaping (Int?) -> Void) -> Void {
        wolframAlpha(query: "prime \(self.store.state.count)") { result in
            callback(
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
            )
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