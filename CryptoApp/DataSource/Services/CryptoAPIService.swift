//
//  CryptoAPIService.swift
//  CryptoApp
//
//  Created by Aleksandr Morozov on 22/10/24.
//

import Foundation
import CoreData

final class CryptoAPIService {
    
    //Properties
    static let shared = CryptoAPIService()  // Singleton instance
    
    private let baseURL = "https://api.coingecko.com/api/v3/coins/markets"
    private let currencyQuery = "?vs_currency=usd"
        
    //Possible Improvement -> Allow custom Sessions for Testing:
//    init(session: URLSession = .shared) {
//        self.session = session
//    }
//    
    func fetchCryptos(limit: Int = 20) async throws -> [Crypto] {
        
        let urlString = "\(baseURL)\(currencyQuery)&per_page=\(limit)"
        
        guard let url = URL(string: urlString) else {
            throw CryptoAPIError.invalidURL
        }
        // Perform the async network request
        let (data, response) = try await URLSession.shared.data(from: url)

        // Check if the response is valid and has status code 200 (OK)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            print("Invalid response: \(response)")
            throw CryptoAPIError.invalidResponse
        }

        // Decode the data into [Crypto] model
        do {
            let cryptos = try JSONDecoder().decode([Crypto].self, from: data)
            return cryptos
        } catch let decodingError {
            print("Decoding failed with error: \(decodingError)")
            throw CryptoAPIError.decodingFailed
        }
    }
}

enum CryptoAPIError: Error {
    case invalidURL
    case invalidResponse
    case decodingFailed
    case other(Error)
}
