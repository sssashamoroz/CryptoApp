//
//  CryptoRepository.swift
//  CryptoApp
//
//  Created by Aleksandr Morozov on 22/10/24.
//

import Foundation
import CoreData

protocol CryptoRepositoryProtocol {
    func fetchCryptos(forceRefresh: Bool) async throws -> [Crypto]  // Accepts forceRefresh argument
    func refreshCryptos() async throws  // Additional refresh method
}

final class CryptoRepository: CryptoRepositoryProtocol {
    
    private let service: CryptoAPIService
    private let coreDataStack: CoreDataStack

    init(service: CryptoAPIService = CryptoAPIService.shared, stack: CoreDataStack = CoreDataStack.shared) {
        self.service = service
        self.coreDataStack = stack
    }
    
    // Fetch cryptos from API or cache
    func fetchCryptos(forceRefresh: Bool = false) async throws -> [Crypto] {
        // If we're forcing refresh, go straight to API
        if forceRefresh {
            print("🌐 Fetching cryptos from API (forced refresh)...")
            let cryptos = try await service.fetchCryptos()
            await saveOrUpdateCryptos(cryptos)
            return cryptos
        }

        // Otherwise, check cache first
        let cachedCryptos = try loadCachedCryptos()
        
        if !cachedCryptos.isEmpty {
            print("💽 Loaded \(cachedCryptos.count) cached cryptos from Core Data.")
            return cachedCryptos.map { mapEntityToModel($0) }
        } else {
            print("🌐 No cached data. Fetching cryptos from API...")
            let cryptos = try await service.fetchCryptos()
            await saveOrUpdateCryptos(cryptos)
            return cryptos
        }
    }
    
    // Refresh cryptos (updating or inserting instead of deleting)
    func refreshCryptos() async throws {
        print("🌐 Fetching cryptos from API for refresh...")
        let cryptos = try await service.fetchCryptos()
        
        await saveOrUpdateCryptos(cryptos)
    }

    // MARK: - Private Helper Methods

    // Load cached cryptos from Core Data
    private func loadCachedCryptos() throws -> [CryptoEntity] {
        let request: NSFetchRequest<CryptoEntity> = CryptoEntity.fetchRequest()
        let cachedCryptos = try coreDataStack.viewContext.fetch(request)
        print("💽 Loaded \(cachedCryptos.count) cached cryptos from Core Data.")
        return cachedCryptos
    }

    // Save or update cryptos in Core Data, preserving "isFavorite"
    private func saveOrUpdateCryptos(_ cryptos: [Crypto]) async {
        let context = coreDataStack.viewContext
        
        //Fetch existing cryptos from Core Data
        let existingCryptos = loadExistingCryptos()
        let existingCryptoMap = Dictionary(uniqueKeysWithValues: existingCryptos.map { ($0.id ?? "", $0) })
        
        // Counters to track the number of updates and additions
        var updatedCount = 0
        var addedCount = 0
        
        //Loop through the new cryptos and update or - insert (in case of new ones)
        await context.perform {
            for crypto in cryptos {
                if let existingCrypto = existingCryptoMap[crypto.id] {
                    self.updateCryptoEntity(existingCrypto, with: crypto)
                    updatedCount += 1
                } else {
                    //Insert new crypto
                    let newCryptoEntity = CryptoEntity(context: context)
                    self.mapModelToEntity(crypto, newCryptoEntity)
                    addedCount += 1
                }
            }
            
            // Step 5: Save context
            do {
                try context.save()
                print("✅ Successfully updated Core Data. \(updatedCount) cryptos updated, \(addedCount) cryptos added.")
            } catch {
                print("❌ Error saving to Core Data: \(error.localizedDescription)")
            }
        }
    }

    // Helper function to load all existing cryptos from Core Data
    private func loadExistingCryptos() -> [CryptoEntity] {
        let request: NSFetchRequest<CryptoEntity> = CryptoEntity.fetchRequest()
        do {
            return try coreDataStack.viewContext.fetch(request)
        } catch {
            print("❌ Failed to fetch existing cryptos: \(error.localizedDescription)")
            return []
        }
    }

    // Helper function to update an existing CryptoEntity without changing isFavorite
    private func updateCryptoEntity(_ cryptoEntity: CryptoEntity, with crypto: Crypto) {
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
        cryptoEntity.isFavorite = cryptoEntity.isFavorite // Preserve isFavorite
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
            atlDate: cryptoEntity.atlDate ?? Date(),
            isFavorite: cryptoEntity.isFavorite // Preserve favorite status
        )
    }
}
