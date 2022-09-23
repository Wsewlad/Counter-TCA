//
//  Model.swift
//  Counter-TCA
//
//  Created by  Vladyslav Fil on 22.09.2022.
//

import Foundation
import SwiftUI
import Collections

let wolframAlphaApiKey = "T8R7LH-X7L2V6G98P"

final class Store<State>: ObservableObject {
    @Published var state: State
    
    init(state: State) {
        self.state = state
    }
}

struct AppState {
    var count: Int = 0
    var favoritePrimes: OrderedSet<Int> = []
    var loggedInUser: User? = nil
    var activityFeed: [Activity] = []
}

//MARK: - Wolfram Alpha
extension AppState {
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
        wolframAlpha(query: "prime \(self.count)") { result in
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

//MARK: - Favorites
extension AppState {
    var isInFavorites: Bool {
        self.favoritePrimes.contains(self.count)
    }
    
    mutating func toggleFavorites() {
        if isInFavorites {
            self.favoritePrimes.remove(self.count)
            self.activityFeed.append(.init(timestamp: .now, type: .removeFavoritePrime(self.count)))
        } else {
            self.favoritePrimes.append(self.count)
            self.activityFeed.append(.init(timestamp: .now, type: .addedFavoritePrime(self.count)))
        }
    }
    
    mutating func removeFromFavorites(at indexSet: IndexSet) {
        for index in indexSet {
            self.favoritePrimes.remove(at: index)
            self.activityFeed.append(.init(timestamp: .now, type: .removeFavoritePrime(self.count)))
        }
    }
}

//MARK: - Counter
extension AppState {
    mutating func increment() {
        count += 1
    }
    
    mutating func decrement() {
        guard count >= 1 else { return }
        count -= 1
    }
}
