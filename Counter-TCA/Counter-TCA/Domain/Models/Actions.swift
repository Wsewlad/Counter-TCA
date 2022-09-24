//
//  Actions.swift
//  Counter-TCA
//
//  Created by  Vladyslav Fil on 23.09.2022.
//

import Foundation

enum AppAction {
    case counter(CounterAction)
    case primeModal(PrimeModalAction)
    case favoritePrimes(FavoritePrimesAction)
    
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
    
    var favoritePrimes: FavoritePrimesAction? {
        get {
            guard case let .favoritePrimes(value) = self else { return nil }
            return value
        }
        set {
            guard case .favoritePrimes = self, let newValue = newValue else { return }
            self = .favoritePrimes(newValue)
        }
    }
}

enum CounterAction {
    case decrTapped
    case incrTapped
}

enum PrimeModalAction {
    case saveFavoritePrimeTapped
    case removeFavoritePrimeTapped
}

enum FavoritePrimesAction {
    case deleteFavoritePrimes(IndexSet)
}




enum Actions {
    struct IncrementCounter: EquatableAction {}
    struct DecrementCounter: EquatableAction {}
}

typealias EquatableAction = Equatable & Actionable

protocol Actionable {}

extension Actionable where Self: Equatable {
    func eraseToAnyAction(fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) -> AnyAction {
        AnyAction(self, fileName: fileName, functionName: functionName, lineNumber: lineNumber)
    }
}

struct AnyAction {
    let value: Actionable
    
    let anyValue: Any
    let equalTo: (Any) -> Bool
    let actionDescription: String
    
    init<T: Actionable>(_ value: T, fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) where T: Equatable {
        self.value = value
        self.anyValue = value
        self.equalTo = { $0 as? T == value }
        
        let fileURL = NSURL(fileURLWithPath: fileName).lastPathComponent ?? "Unknown file"
        actionDescription = "\(String(describing: value)) from \(fileURL) - \(functionName) at line \(lineNumber)"
    }
}

// MARK: - Equatable
extension AnyAction: Equatable {
    public static func == (lhs: AnyAction, rhs: AnyAction) -> Bool {
        lhs.equalTo(rhs.anyValue)
    }
}

// MARK: - CustomDebugStringConvertible
extension AnyAction: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        actionDescription
    }
}
