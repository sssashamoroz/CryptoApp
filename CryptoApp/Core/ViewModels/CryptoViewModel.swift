//
//  CryptoListViewModel.swift
//  CryptoApp
//
//  Created by Aleksandr Morozov on 22/10/24.
//

import Foundation
import Combine


@MainActor
class CryptoViewModel: ObservableObject {
    
    // The repository that will fetch data from the network or cache
    private let repository: CryptoRepositoryProtocol
    
    @Published var cryptos: [Crypto] = []
    @Published var filteredCryptos: [Crypto] = [] // Filtered data for search results
    @Published var favorites: [Crypto] = []      // Separate favorites list

    @Published var lastRefresh: Date?
    
    @Published var searchText: String = "" {
        didSet {
            search(by: searchText)
        }
    }

    @Published var state: AppState = .loading
    
    // Dependency injection with default CryptoRepository
    init(repository: CryptoRepositoryProtocol = CryptoRepository()) {
        self.repository = repository
    }
    
    
    // Fetch Data on View Load
    func fetchData() async {
        print("🔄 Starting data fetch...")
        
        state = .loading
        do {
            cryptos = try await repository.fetchCryptos(forceRefresh: false)
            filteredCryptos = cryptos
            lastRefresh = Date()
            sortCryptosByMarketCapRank()
            state = .success
            print("✅ Data fetched successfully.")
        } catch {
            state = .error(error)
            print("❌ Error fetching data: \(error.localizedDescription)")
        }
    }
    
    // Refresh Data when user pulls to refresh
    func refreshData() async {
        print("🔄 Refreshing data manually...")
        do {
            // Refetch data and bypass cache
            cryptos = try await repository.fetchCryptos(forceRefresh: true)
            lastRefresh = Date() 
            sortCryptosByMarketCapRank()
            state = .success
            print("🔄 Data refreshed successfully.")
        } catch {
            state = .error(error)
            print("❌ Error refreshing data: \(error.localizedDescription)")
        }
    }
    
    // Sort cryptos by "marketCapRank" - placing nil values at the end
    private func sortCryptosByMarketCapRank() {
        cryptos.sort {
            guard let rank1 = $0.marketCapRank, let rank2 = $1.marketCapRank else {
                return $0.marketCapRank != nil
            }
            return rank1 < rank2
        }
    }
    
    func search(by text: String) {
        if text.isEmpty {
            filteredCryptos = cryptos
        } else {
            //Prioritize exact symbol match (case insensitive)
            let exactSymbolMatches = cryptos.filter { crypto in
                return crypto.symbol?.lowercased() == text.lowercased()
            }
            
            //Fallback to name or partial symbol match if no exact symbol matches
            let nameOrSymbolMatches = cryptos.filter { crypto in
                (crypto.name?.lowercased().contains(text.lowercased()) ?? false) ||
                (crypto.symbol?.lowercased().contains(text.lowercased()) ?? false)
            }
            
            // Combine results, prioritizing exact symbol matches first
            filteredCryptos = exactSymbolMatches + nameOrSymbolMatches.filter { !exactSymbolMatches.contains($0) }
        }
    }
    
    
    func toggleFavorite(for crypto: Crypto) async {
        // Update in main cryptos array
        if let index = cryptos.firstIndex(where: { $0.id == crypto.id }) {
            cryptos[index].isFavorite.toggle()
            let isFavorite = cryptos[index].isFavorite

            // Update Core Data
            await repository.updateFavoriteStatus(for: cryptos[index], isFavorite: isFavorite)

            // Update favorites array
            if isFavorite {
                favorites.append(cryptos[index])
            } else {
                favorites.removeAll { $0.id == crypto.id }
            }

            // Update filteredCryptos array
            if let filteredIndex = filteredCryptos.firstIndex(where: { $0.id == crypto.id }) {
                filteredCryptos[filteredIndex].isFavorite = isFavorite
            }
        }
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
