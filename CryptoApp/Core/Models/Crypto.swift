//
//  Crypto.swift
//  CryptoApp
//
//  Created by Aleksandr Morozov on 22/10/24.
//

import Foundation

struct Crypto: Codable, Identifiable {
    let id: String
    let symbol: String
    let name: String
    let imageURL: String
    let marketCapRank: Double
    let currentPrice: Double
    let marketCap: Double
    let totalVolume: Double
    let high24h: Double
    let low24h: Double
    let priceChange24h: Double
    let lastUpdated: Date
    let marketCapChange24h: Double?
    let marketCapChangePercentage24h: Double?
    let totalSupply: Double?

    // Map JSON keys to Swift property names
    enum CodingKeys: String, CodingKey {
        case id, symbol, name
        case imageURL = "image"
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case totalVolume = "total_volume"
        case high24h = "high_24h"
        case low24h = "low_24h"
        case priceChange24h = "price_change_24h"
        case lastUpdated = "last_updated"
        case marketCapRank = "market_cap_rank"
        case marketCapChange24h = "market_cap_change_24h"
        case marketCapChangePercentage24h = "market_cap_change_percentage_24h"
        case totalSupply = "total_supply"
    }
}
