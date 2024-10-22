//
//  CryptoRowView.swift
//  CryptoApp
//
//  Created by Aleksandr Morozov on 22/10/24.
//

import SwiftUI

struct CryptoRowView: View {
    let crypto: Crypto
    
    var body: some View {
        HStack {
            // Crypto Image (Load asynchronously)
            AsyncImage(url: URL(string: crypto.imageURL ?? "")) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            
            // Crypto Name and Symbol
            VStack(alignment: .leading) {
                Text(crypto.name ?? "")
                    .font(.headline)
                Text(crypto.symbol?.uppercased() ?? "")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Crypto Current Price
            Text(String(format: "$%.2f", crypto.currentPrice ?? 0))
                .font(.headline)
        }
        .padding()
    }
}

#Preview {
    CryptoRowView(crypto: Crypto(
        id: "bitcoin",
        symbol: "btc",
        name: "Bitcoin",
        imageURL: "https://coin-images.coingecko.com/coins/images/1/large/bitcoin.png?1696501400",
        marketCapRank: 1,
        currentPrice: 67342,
        marketCap: 1331206384537,
        totalVolume: 36770950539,
        high24h: 67941,
        low24h: 66669,
        priceChange24h: -238.7735073662334,
        lastUpdated: Date(),
        marketCapChange24h: -4781756194.043213,
        marketCapChangePercentage24h: -0.35792,
        totalSupply: 21000000.0,
        maxSupply: 21000000.0,
        ath: 73738.0,
        athChangePercentage: -8.6,
        athDate: Date(),
        atl: 67.81,
        atlChangePercentage: 99197.47108,
        atlDate: Date()
    ))
}
