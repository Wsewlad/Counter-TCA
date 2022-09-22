//
//  WolframAlphaResult.swift
//  Counter-TCA
//
//  Created by  Vladyslav Fil on 23.09.2022.
//

import Foundation

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
