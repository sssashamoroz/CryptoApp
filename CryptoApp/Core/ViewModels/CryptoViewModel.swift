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
    
    
    // Fetch Data
    func fetchData() async {
        
        state = .loading
        do {
            cryptos = try await repository.fetchCryptos()
            state = .success
        } catch {
            state = .error(error)
        }
    }
    
    // RefreshData (For manual updates)
    func refreshData() async {
        await fetchData()
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
