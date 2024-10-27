//
//  CryptoListViewModel.swift
//  CryptoApp
//
//  Created by Aleksandr Morozov on 22/10/24.
//

import Foundation
import SwiftUI
import Network
import Combine

@MainActor
class CryptoViewModel: ObservableObject {
    
    private let repository: CryptoRepository
    
    @Published var cryptos: [Crypto] = [] // Main data array
    @Published var filteredCryptos: [Crypto] = [] // Filtered data for search results and favorites display
    @Published var lastRefresh: Date?
    private var favoriteIDs: [String] = []
    
    //Network
    private let networkMonitor = NWPathMonitor() // Network monitoring
    private let queue = DispatchQueue(label: "NetworkMonitor") // Queue for network monitoring
    @Published var isOnline: Bool = true
        
    
    
    @Published var searchText: String = "" {
        didSet {
            filterCryptos()
        }
    }
    
    @Published var state: AppState = .loading
    
    init(repository: CryptoRepository = CryptoRepository()) {
        self.repository = repository
        setupNetworkMonitoring() // Start monitoring
    }
    
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { path in
            Task { @MainActor in
                withAnimation{
                    self.isOnline = path.status == .satisfied
                }
            }
        }
        networkMonitor.start(queue: queue)
    }
    
    // Fetch Data on View Load, including favorites
    func fetchData() async {
        state = .loading
        do {
            cryptos = try await repository.fetchCryptos(forceRefresh: false)
            favoriteIDs = await repository.fetchFavorites() // Fetch favorite IDs
            
            updateFavoriteStatus()
            
            lastRefresh = Date()
            filterCryptos()
            state = .success
        } catch {
            state = .error(error)
        }
    }
    
    // Refresh Data
    func refreshData() async {
        do {
            cryptos = try await repository.refreshCryptos()
            favoriteIDs = await repository.fetchFavorites()
            updateFavoriteStatus()
            lastRefresh = Date()
            filterCryptos()
            state = .success
        } catch {
            state = .error(error)
        }
    }
    
    func filterCryptos() {
        if searchText.isEmpty {
            // Show favorites at the top, sorted by market cap rank
            filteredCryptos = cryptos.sorted { lhs, rhs in
                let lhsIsFavorite = favoriteIDs.contains(lhs.id)
                let rhsIsFavorite = favoriteIDs.contains(rhs.id)
                
                if lhsIsFavorite != rhsIsFavorite {
                    return lhsIsFavorite && !rhsIsFavorite
                } else {
                    // Sort by market cap rank if both are favorites or both are non-favorites
                    return (lhs.marketCapRank ?? Double(Int.max)) < (rhs.marketCapRank ?? Double(Int.max))
                }
            }
        } else {
            // Filter based on search text and prioritize favorites, then market cap rank
            let matches = cryptos.filter {
                ($0.name?.lowercased().contains(searchText.lowercased()) ?? false) ||
                ($0.symbol?.lowercased().contains(searchText.lowercased()) ?? false)
            }
            filteredCryptos = matches.sorted { lhs, rhs in
                let lhsIsFavorite = favoriteIDs.contains(lhs.id)
                let rhsIsFavorite = favoriteIDs.contains(rhs.id)
                
                if lhsIsFavorite != rhsIsFavorite {
                    return lhsIsFavorite && !rhsIsFavorite
                } else {
                    return (lhs.marketCapRank ?? Double(Int.max)) < (rhs.marketCapRank ?? Double(Int.max))
                }
            }
        }
    }
    
    // Update cryptos to mark favorites in the list
    private func updateFavoriteStatus() {
        cryptos = cryptos.map { crypto in
            var updatedCrypto = crypto
            updatedCrypto.isFavorite = favoriteIDs.contains(crypto.id)
            return updatedCrypto
        }
    }
    
    // Toggle favorite status for a specific crypto
    func toggleFavorite(for crypto: Crypto) async {
        await repository.toggleFavoriteStatus(for: crypto.id)
        favoriteIDs = await repository.fetchFavorites()
        updateFavoriteStatus()
        filterCryptos()
    }
}

//Posible improvement -> Move to Enums folder
enum AppState: Equatable {
    case loading
    case success
    case error(Error)
    
    static func == (lhs: AppState, rhs: AppState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading), (.success, .success):
            return true
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}
