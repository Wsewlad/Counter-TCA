//
//  Model.swift
//  Counter-TCA
//
//  Created by  Vladyslav Fil on 22.09.2022.
//

import Foundation
import SwiftUI
import Collections
import PrimeModal

let wolframAlphaApiKey = "T8R7LH-X7L2V6G98P"

struct AppState {
    var count: Int = 0
    var favoritePrimes: OrderedSet<Int> = []
    var loggedInUser: User? = nil
    var activityFeed: [Activity] = []
}

extension AppState {
    var primeModal: PrimeModalState {
        get {
            .init(count: self.count, favoritePrimes: self.favoritePrimes)
        }
        set {
            self.count = newValue.count
            self.favoritePrimes = newValue.favoritePrimes
        }
    }
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
        wolframAlpha(query: "prime \(self.primeModal.count)") { result in
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

//MARK: - activity Feed
func activityFeed(
    _ reducer: @escaping (inout AppState, AppAction) -> Void
) -> (inout AppState, AppAction) -> Void {
    return { state, action in
        switch action {
        case .counter:
            break

        case .primeModal(.removeFavoritePrimeTapped):
            state.activityFeed.append(
                .init(timestamp: Date(), type: .removedFavoritePrime(state.count))
            )

        case .primeModal(.saveFavoritePrimeTapped):
            state.activityFeed.append(
                .init(timestamp: Date(), type: .saveFavoritePrimeTapped(state.count))
            )

        case let .favoritePrimes(.deleteFavoritePrimes(indexSet)):
            for index in indexSet {
                state.activityFeed.append(
                    .init(
                        timestamp: Date(),
                        type: .removedFavoritePrime(state.favoritePrimes[index])
                    )
                )
            }
        }
        
        reducer(&state, action)
    }
}
