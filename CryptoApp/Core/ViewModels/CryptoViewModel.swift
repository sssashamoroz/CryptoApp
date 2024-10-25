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
    
    @Published var cryptos: [Crypto] = []
    @Published var state: AppState = .loading
    
    // The repository that will fetch data from the network or cache
    private let repository: CryptoRepositoryProtocol
    
    // Dependency injection with default CryptoRepository
    init(repository: CryptoRepositoryProtocol = CryptoRepository()) {
        self.repository = repository
    }
    
    
    // Fetch Data on View Load
    func fetchData() async {
        print("🔄 Starting data fetch...")
        
        state = .loading
        do {
            cryptos = try await repository.fetchCryptos()
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
            cryptos = try await repository.fetchCryptos()
            state = .success
            print("🔄 Data refreshed successfully.")
        } catch {
            state = .error(error)
            print("❌ Error refreshing data: \(error.localizedDescription)")
        }
    }
    
    // Filter for Saerch Component
    func search(by name: String) {
        if name.isEmpty {
            // If search text is empty, reset to all cryptos
            Task {
                await fetchData()
            }
        } else {
            // Filter cryptos by name
            // Posible improvement -> Add filtering by symbol
            
            cryptos = cryptos.filter { crypto in
                if let cryptoName = crypto.name?.lowercased() {
                    return cryptoName.contains(name.lowercased())
                } else {
                    return false // If name is nil, we don't include it in the results
                }
            }
        }
    }
}


//Posible improvement -> Move to Enums folder
enum AppState {
    case loading
    case success
    case error(Error)
}
