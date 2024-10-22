//
//  Crypto.swift
//  CryptoApp
//
//  Created by Aleksandr Morozov on 22/10/24.
//

import Foundation

struct Crypto: Identifiable, Codable {
    let id: String?
    let symbol: String?
    let name: String?
    let imageURL: String?
    let marketCapRank: Double?
    let currentPrice: Double?
    let marketCap: Double?
    let totalVolume: Double?
    let high24h: Double?
    let low24h: Double?
    let priceChange24h: Double?
    let lastUpdated: Date?
    let marketCapChange24h: Double?
    let marketCapChangePercentage24h: Double?
    let totalSupply: Double?
    let maxSupply: Double?
    let ath: Double?
    let athChangePercentage: Double?
    let athDate: Date?
    let atl: Double?
    let atlChangePercentage: Double?
    let atlDate: Date?
    let isFavorite: Bool = false
    
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
        case priceChangePercentage24h = "price_change_percentage_24h"
        case marketCapChange24h = "market_cap_change_24h"
        case marketCapChangePercentage24h = "market_cap_change_percentage_24h"
        case totalSupply = "total_supply"
        case maxSupply = "max_supply"
        case ath = "ath"
        case athChangePercentage = "ath_change_percentage"
        case athDate = "ath_date"
        case atl = "atl"
        case atlChangePercentage = "atl_change_percentage"
        case atlDate = "atl_date"
    }
    
    
    // Initializer
    init(id: String, symbol: String, name: String, imageURL: String, marketCapRank: Double, currentPrice: Double, marketCap: Double, totalVolume: Double, high24h: Double, low24h: Double, priceChange24h: Double, lastUpdated: Date, marketCapChange24h: Double, marketCapChangePercentage24h: Double, totalSupply: Double, maxSupply: Double, ath: Double, athChangePercentage: Double, athDate: Date, atl: Double, atlChangePercentage: Double, atlDate: Date, isFavorite: Bool = false) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.imageURL = imageURL
        self.marketCapRank = marketCapRank
        self.currentPrice = currentPrice
        self.marketCap = marketCap
        self.totalVolume = totalVolume
        self.high24h = high24h
        self.low24h = low24h
        self.priceChange24h = priceChange24h
        self.lastUpdated = lastUpdated
        self.marketCapChange24h = marketCapChange24h
        self.marketCapChangePercentage24h = marketCapChangePercentage24h
        self.totalSupply = totalSupply
        self.maxSupply = maxSupply
        self.ath = ath
        self.athChangePercentage = athChangePercentage
        self.athDate = athDate
        self.atl = atl
        self.atlChangePercentage = atlChangePercentage
        self.atlDate = atlDate
    }

    
    // MARK: Comply to Codable
    //Custom Decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode all required properties
        id = try? container.decode(String.self, forKey: .id)
        symbol = try? container.decode(String.self, forKey: .symbol)
        name = try? container.decode(String.self, forKey: .name)
        imageURL = try? container.decode(String.self, forKey: .imageURL)
        currentPrice = try? container.decode(Double.self, forKey: .currentPrice)
        marketCap = try? container.decode(Double.self, forKey: .marketCap)
        totalVolume = try? container.decode(Double.self, forKey: .totalVolume)
        high24h = try? container.decode(Double.self, forKey: .high24h)
        low24h = try? container.decode(Double.self, forKey: .low24h)
        priceChange24h = try? container.decode(Double.self, forKey: .priceChange24h)
        
        // Decode `lastUpdated` as String and convert to Date
        let lastUpdatedString = try? container.decode(String.self, forKey: .lastUpdated)
        lastUpdated = ISO8601DateFormatter().date(from: lastUpdatedString ?? "")
        
        // Optional properties
        marketCapRank = try? container.decode(Double.self, forKey: .marketCapRank)
        marketCapChange24h = try? container.decode(Double.self, forKey: .marketCapChange24h)
        marketCapChangePercentage24h = try? container.decode(Double.self, forKey: .marketCapChangePercentage24h)
        totalSupply = try? container.decode(Double.self, forKey: .totalSupply)
        
        // Safely decode nullable `maxSupply`
        maxSupply = try? container.decodeIfPresent(Double.self, forKey: .maxSupply) ?? nil
        
        ath = try? container.decode(Double.self, forKey: .ath)
        athChangePercentage = try? container.decode(Double.self, forKey: .athChangePercentage)
        
        let athDateString = try? container.decode(String.self, forKey: .athDate)
        athDate = ISO8601DateFormatter().date(from: athDateString ?? "")
        
        atl = try? container.decode(Double.self, forKey: .atl)
        atlChangePercentage = try? container.decode(Double.self, forKey: .atlChangePercentage)
        
        let atlDateString = try? container.decode(String.self, forKey: .atlDate)
        atlDate = ISO8601DateFormatter().date(from: atlDateString ?? "")
    }
    
    //Custom Encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(symbol, forKey: .symbol)
        try container.encode(name, forKey: .name)
        try container.encode(imageURL, forKey: .imageURL)
        try container.encode(currentPrice, forKey: .currentPrice)
        try container.encode(marketCap, forKey: .marketCap)
        try container.encode(totalVolume, forKey: .totalVolume)
        try container.encode(high24h, forKey: .high24h)
        try container.encode(low24h, forKey: .low24h)
        try container.encode(priceChange24h, forKey: .priceChange24h)
        try container.encode(marketCapRank, forKey: .marketCapRank)
        try container.encode(marketCapChange24h, forKey: .marketCapChange24h)
        try container.encode(marketCapChangePercentage24h, forKey: .marketCapChangePercentage24h)
        try container.encode(totalSupply, forKey: .totalSupply)
        try container.encode(maxSupply, forKey: .maxSupply)
        try container.encode(ath, forKey: .ath)
        try container.encode(athChangePercentage, forKey: .athChangePercentage)

        // Encode dates
        let isoFormatter = ISO8601DateFormatter()
        try container.encode(isoFormatter.string(from: lastUpdated ?? Date()), forKey: .lastUpdated)
        try container.encode(isoFormatter.string(from: athDate ?? Date()), forKey: .athDate)
        try container.encode(isoFormatter.string(from: atlDate ?? Date()), forKey: .atlDate)
    }
}
