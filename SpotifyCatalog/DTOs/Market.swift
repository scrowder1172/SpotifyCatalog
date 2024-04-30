//
//  Market.swift
//  SpotifyCatalog
//
//  Created by SCOTT CROWDER on 4/30/24.
//

import Foundation

struct Market: Identifiable {
    let country: String
    let code: String
    
    var id: String { code }
    
    static let knownMarkets: [Market] = [
        .init(country: "United States", code: "US"),
        .init(country: "Canada", code: "CA"),
        .init(country: "United Kingdom", code: "GB"),
        .init(country: "Australia", code: "AU"),
        .init(country: "Spain", code: "ES"),
        .init(country: "Germany", code: "DE"),
        .init(country: "France", code: "FR"),
    ]
}
