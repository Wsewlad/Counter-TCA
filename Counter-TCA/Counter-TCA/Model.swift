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

@MainActor
final class Model: ObservableObject {
    @Published private(set) var count: Int = 0
    @Published private(set) var favoritePrimes: OrderedSet<Int> = []
}

//MARK: - Wolfram Alpha
extension Model {
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
extension Model {
    var isInFavorites: Bool {
        favoritePrimes.contains(self.count)
    }
    
    func toggleFavorites() {
        if isInFavorites {
            favoritePrimes.remove(self.count)
        } else {
            favoritePrimes.append(self.count)
        }
    }
    
    func removeFromFavorites(on indexSet: IndexSet) {
        for index in indexSet {
            self.favoritePrimes.remove(at: index)
        }
    }
}

//MARK: - Counter
extension Model {
    func increment() {
        count += 1
    }
    
    func decrement() {
        guard count >= 1 else { return }
        count -= 1
    }
}
