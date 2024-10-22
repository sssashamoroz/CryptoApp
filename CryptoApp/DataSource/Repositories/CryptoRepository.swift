//
//  CryptoRepository.swift
//  CryptoApp
//
//  Created by Aleksandr Morozov on 22/10/24.
//

import Foundation
import CoreData

protocol CryptoRepositoryProtocol {
    func fetchCryptos() async throws -> [Crypto]
}

final class CryptoRepository: CryptoRepositoryProtocol {
    
    private let service: CryptoAPIService
    private let coreDataStack: CoreDataStack

    init(service: CryptoAPIService = CryptoAPIService.shared, stack: CoreDataStack = CoreDataStack.shared) {
        self.service = service
        self.coreDataStack = stack
    }
    
    // Fetch cryptos, prioritize cached data, fall back to API if not present
    func fetchCryptos() async throws -> [Crypto] {
        do {
            // Try to load cached cryptos from Core Data
            let cachedCryptos = try loadCachedCryptos()
            if !cachedCryptos.isEmpty {
                return cachedCryptos.map { mapEntityToModel($0) }
            } else {
                // No cached data, fetch from API
                let cryptos = try await service.fetchCryptos()
                await saveToCoreData(cryptos)
                return cryptos
            }
        } catch {
            print("Error fetching cryptos: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Private Helper Methods

    // Load cached cryptos from Core Data
    private func loadCachedCryptos() throws -> [CryptoEntity] {
        let request: NSFetchRequest<CryptoEntity> = CryptoEntity.fetchRequest()
        return try coreDataStack.viewContext.fetch(request)
    }

    // Save newly fetched cryptos to Core Data
    private func saveToCoreData(_ cryptos: [Crypto]) async {
        let context = coreDataStack.viewContext
        await context.perform {
            for crypto in cryptos {
                let cryptoEntity = CryptoEntity(context: context)
                self.mapModelToEntity(crypto, cryptoEntity)
            }
            do {
                try context.save()
            } catch {
                print("Error saving to Core Data: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Mapping Functions

    // Map Crypto model to Core Data entity
    private func mapModelToEntity(_ crypto: Crypto, _ cryptoEntity: CryptoEntity) {
        cryptoEntity.id = crypto.id
        cryptoEntity.symbol = crypto.symbol
        cryptoEntity.name = crypto.name
        cryptoEntity.imageURL = crypto.imageURL
        cryptoEntity.currentPrice = crypto.currentPrice ?? 0
        cryptoEntity.marketCap = crypto.marketCap ?? 0
        cryptoEntity.totalVolume = crypto.totalVolume ?? 0
        cryptoEntity.high24h = crypto.high24h ?? 0
        cryptoEntity.low24h = crypto.low24h ?? 0
        cryptoEntity.priceChange24h = crypto.priceChange24h ?? 0
        cryptoEntity.lastUpdated = crypto.lastUpdated
        cryptoEntity.isFavorite = false // Default, can be set elsewhere if needed
    }

    // Map Core Data entity to Crypto model
    private func mapEntityToModel(_ cryptoEntity: CryptoEntity) -> Crypto {
        return Crypto(
            id: cryptoEntity.id ?? "",
            symbol: cryptoEntity.symbol ?? "",
            name: cryptoEntity.name ?? "",
            imageURL: cryptoEntity.imageURL ?? "",
            marketCapRank: cryptoEntity.marketCapRank,
            currentPrice: cryptoEntity.currentPrice,
            marketCap: cryptoEntity.marketCap,
            totalVolume: cryptoEntity.totalVolume,
            high24h: cryptoEntity.high24h,
            low24h: cryptoEntity.low24h,
            priceChange24h: cryptoEntity.priceChange24h,
            lastUpdated: cryptoEntity.lastUpdated ?? Date(),
            marketCapChange24h: cryptoEntity.marketCapChange24h,
            marketCapChangePercentage24h: cryptoEntity.marketCapChangePercentage24h,
            totalSupply: cryptoEntity.totalSupply,
            maxSupply: cryptoEntity.maxSupply,
            ath: cryptoEntity.ath,
            athChangePercentage: cryptoEntity.athChangePercentage,
            athDate: cryptoEntity.athDate ?? Date(),
            atl: cryptoEntity.atl,
            atlChangePercentage: cryptoEntity.atlChangePercentage,
            atlDate: cryptoEntity.atlDate ?? Date()
        )
    }
}
