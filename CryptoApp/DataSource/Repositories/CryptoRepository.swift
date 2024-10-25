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
    
    // Fetch cryptos, prioritize API, but fall back to cached data if needed
    func fetchCryptos() async throws -> [Crypto] {
        // Try to fetch from API first
        do {
            let cryptos = try await service.fetchCryptos()
            print("✅ Successfully fetched cryptos from API.")
            
            // Clean up old cache
            deleteAllCachedCryptos()

            // Save fresh data to Core Data
            await saveToCoreData(cryptos)
            print("💾 Cached new cryptos to Core Data.")
            return cryptos
        } catch {
            // If API fails, fall back to cache
            print("⚠️ Failed to fetch cryptos from API: \(error.localizedDescription). Falling back to Core Data cache.")
            let cachedCryptos = try loadCachedCryptos()
            if cachedCryptos.isEmpty {
                print("❌ No cached cryptos available.")
                throw error
            }
            return cachedCryptos.map { mapEntityToModel($0) }
        }
    }

    // MARK: - Private Helper Methods

    // Load cached cryptos from Core Data
    private func loadCachedCryptos() throws -> [CryptoEntity] {
        let request: NSFetchRequest<CryptoEntity> = CryptoEntity.fetchRequest()
        let cachedCryptos = try coreDataStack.viewContext.fetch(request)
        print("💽 Loaded \(cachedCryptos.count) cached cryptos from Core Data.")
        return cachedCryptos
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
                print("✅ Successfully saved new cryptos to Core Data.")
            } catch {
                print("❌ Error saving to Core Data: \(error.localizedDescription)")
            }
        }
    }

    // Delete all cached cryptos from Core Data
    private func deleteAllCachedCryptos() {
        let context = coreDataStack.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CryptoEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save() // Persist the deletion
            print("🗑️ Successfully deleted all cached cryptos from Core Data.")
        } catch {
            print("❌ Error deleting cached cryptos: \(error.localizedDescription)")
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
