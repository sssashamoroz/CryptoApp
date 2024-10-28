//
//  CryptoRepository.swift
//  CryptoApp
//
//  Created by Aleksandr Morozov on 22/10/24.
//

import Foundation
import CoreData

final class CryptoRepository {
    
    private let service: CryptoAPIService
    private let coreDataStack: CoreDataStack

    init(service: CryptoAPIService = CryptoAPIService.shared, stack: CoreDataStack = CoreDataStack.shared) {
        self.service = service
        self.coreDataStack = stack
    }
    
    // Fetch cryptos from API or cache
    func fetchCryptos(forceRefresh: Bool = false) async throws -> [Crypto] {
        if forceRefresh {
            let cryptos = try await service.fetchCryptos()
            await saveOrUpdateCryptos(cryptos)
            return cryptos
        }

        let cachedCryptos = try loadCachedCryptos()
        return cachedCryptos.isEmpty ? try await refreshCryptos() : cachedCryptos.map { mapEntityToModel($0) }
    }
    
    // Refresh cryptos by fetching from API and saving to Core Data
    func refreshCryptos() async throws -> [Crypto] {
        let cryptos = try await service.fetchCryptos()
        await saveOrUpdateCryptos(cryptos)
        return cryptos
    }

    // Toggle favorite status by adding or removing FavoriteCrypto entity
    func toggleFavoriteStatus(for cryptoID: String) async {
        let context = coreDataStack.viewContext
        let request: NSFetchRequest<FavoriteCrypto> = FavoriteCrypto.fetchRequest()
        request.predicate = NSPredicate(format: "crypto.id == %@", cryptoID)

        context.performAndWait {
            do {
                if let favorite = try context.fetch(request).first {
                    context.delete(favorite) // Remove favorite if it exists
                } else if let cryptoEntity = fetchCryptoEntity(for: cryptoID) {
                    let newFavorite = FavoriteCrypto(context: context)
                    newFavorite.crypto = cryptoEntity
                    newFavorite.dateAdded = Date()
                }
                try context.save()
            } catch {
                print("Failed to toggle favorite status: \(error)")
            }
        }
    }

    // Fetch all favorite crypto IDs from FavoriteCrypto entities, sorted by dateAdded
    func fetchFavorites() async -> [String] {
        let request: NSFetchRequest<FavoriteCrypto> = FavoriteCrypto.fetchRequest()
        
        // Sort by dateAdded in descending order (newest first)
        request.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        
        let favorites = (try? coreDataStack.viewContext.fetch(request)) ?? []
        
        // Map to crypto IDs
        return favorites.compactMap { $0.crypto?.id }
    }

    // MARK: - Private Helper Methods

    private func fetchCryptoEntity(for cryptoID: String) -> CryptoEntity? {
        let request: NSFetchRequest<CryptoEntity> = CryptoEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", cryptoID)
        return (try? coreDataStack.viewContext.fetch(request))?.first
    }

    private func loadCachedCryptos() throws -> [CryptoEntity] {
        let request: NSFetchRequest<CryptoEntity> = CryptoEntity.fetchRequest()
        return try coreDataStack.viewContext.fetch(request)
    }

    private func saveOrUpdateCryptos(_ cryptos: [Crypto]) async {
        let context = coreDataStack.viewContext
        let existingCryptoMap = Dictionary(uniqueKeysWithValues: (try? loadCachedCryptos().map { ($0.id ?? "", $0) }) ?? [])

        await context.perform {
            for crypto in cryptos {
                if let existingCrypto = existingCryptoMap[crypto.id] {
                    self.updateCryptoEntity(existingCrypto, with: crypto)
                } else {
                    let newCryptoEntity = CryptoEntity(context: context)
                    self.mapModelToEntity(crypto, newCryptoEntity)
                }
            }
            try? context.save()
        }
    }

    // Helper function to update an existing CryptoEntity without changing isFavorite
    private func updateCryptoEntity(_ cryptoEntity: CryptoEntity, with crypto: Crypto) {
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
        cryptoEntity.marketCapRank = crypto.marketCapRank ?? 0
        cryptoEntity.marketCapChange24h = crypto.marketCapChange24h ?? 0
        cryptoEntity.marketCapChangePercentage24h = crypto.marketCapChangePercentage24h ?? 0
        cryptoEntity.totalSupply = crypto.totalSupply ?? 0
        cryptoEntity.maxSupply = crypto.maxSupply ?? 0
        cryptoEntity.ath = crypto.ath ?? 0
        cryptoEntity.athChangePercentage = crypto.athChangePercentage ?? 0
        cryptoEntity.athDate = crypto.athDate
        cryptoEntity.atl = crypto.atl ?? 0
        cryptoEntity.atlChangePercentage = crypto.atlChangePercentage ?? 0
        cryptoEntity.atlDate = crypto.atlDate
        cryptoEntity.isFavorite = crypto.isFavorite
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
        cryptoEntity.lastUpdated = crypto.lastUpdated ?? "NODATE"
        cryptoEntity.marketCapRank = crypto.marketCapRank ?? 9999
        cryptoEntity.marketCapChange24h = crypto.marketCapChange24h ?? 0
        cryptoEntity.marketCapChangePercentage24h = crypto.marketCapChangePercentage24h ?? 0
        cryptoEntity.totalSupply = crypto.totalSupply ?? 0
        cryptoEntity.maxSupply = crypto.maxSupply ?? 0
        cryptoEntity.ath = crypto.ath ?? 0
        cryptoEntity.athChangePercentage = crypto.athChangePercentage ?? 0
        cryptoEntity.athDate = crypto.athDate
        cryptoEntity.atl = crypto.atl ?? 0
        cryptoEntity.atlChangePercentage = crypto.atlChangePercentage ?? 0
        cryptoEntity.atlDate = crypto.atlDate
        cryptoEntity.isFavorite = crypto.isFavorite
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
            lastUpdated: cryptoEntity.lastUpdated ?? "NODATE",
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
            isFavorite: cryptoEntity.isFavorite
        )
    }
}
