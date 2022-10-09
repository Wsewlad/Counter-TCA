//
//  WolframAlpha.swift
//  Counter
//
//  Created by  Vladyslav Fil on 09.10.2022.
//

import Foundation
import ComposableArchitecture

let wolframAlphaApiKey = "T8R7LH-X7L2V6G98P"

func wolframAlpha(query: String) -> Effect<WolframAlphaResult?> {
    var components = URLComponents(string: "https://api.wolframalpha.com/v2/query")!
    components.queryItems = [
        URLQueryItem(name: "input", value: query),
        URLQueryItem(name: "format", value: "plaintext"),
        URLQueryItem(name: "output", value: "JSON"),
        URLQueryItem(name: "appid", value: wolframAlphaApiKey)
    ]

    return URLSession.shared
        .dataTaskPublisher(for: components.url(relativeTo: nil)!)
        .map { data, _ in data }
        .decode(type: WolframAlphaResult?.self, decoder: JSONDecoder())
        .replaceError(with: nil)
        .eraseToEffect()
}

func nthPrime(n: Int) -> Effect<Int?> {
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
    .eraseToEffect()
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
