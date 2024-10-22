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
    let imageURL: URL
    let currentPrice: Double
    let marketCap: Double
    let totalVolume: Double
    let high24h: Double
    let low24h: Double
    let priceChange24h: Double
    let ath: Double
    let atl: Double
    let lastUpdated: Date
    
    // Currently un-used attributes.
    let marketCapRank: Int?
    let fullyDilutedValuation: Double?
    let priceChangePercentage24h: Double?
    let marketCapChange24h: Double?
    let marketCapChangePercentage24h: Double?
    let circulatingSupply: Double?
    let totalSupply: Double?
    let maxSupply: Double?
    let athChangePercentage: Double?
    let athDate: Date?
    let atlChangePercentage: Double?
    let atlDate: Date?
    let roi: Double? // Optional, because it's often null in your example

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
        case ath, atl
        case lastUpdated = "last_updated"
        
        // Currently un-used attributes.
        case marketCapRank = "market_cap_rank"
        case fullyDilutedValuation = "fully_diluted_valuation"
        case priceChangePercentage24h = "price_change_percentage_24h"
        case marketCapChange24h = "market_cap_change_24h"
        case marketCapChangePercentage24h = "market_cap_change_percentage_24h"
        case circulatingSupply = "circulating_supply"
        case totalSupply = "total_supply"
        case maxSupply = "max_supply"
        case athChangePercentage = "ath_change_percentage"
        case athDate = "ath_date"
        case atlChangePercentage = "atl_change_percentage"
        case atlDate = "atl_date"
        case roi
    }
}
