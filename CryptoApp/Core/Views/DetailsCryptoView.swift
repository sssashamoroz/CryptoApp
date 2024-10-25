//
//  DetailsCryptoView.swift
//  CryptoApp
//
//  Created by Aleksandr Morozov on 25/10/24.
//

import SwiftUI

struct DetailsCryptoView: View {
    
    let crypto: Crypto
    var animation: Namespace.ID


    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Name and Image
                VStack {
                    Text(crypto.name ?? "Unknown")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 20)

                    // Display Crypto Image
                    AsyncImage(url: URL(string: crypto.imageURL ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                    } placeholder: {
                        ProgressView() // Placeholder while loading the image
                    }
                    .padding(.bottom, 20)
                }
                
                // Total Volume
                Text("Total Volume: \(crypto.totalVolume?.formatted() ?? "N/A")")
                    .font(.headline)
                
                // Highest Price
                Text("Highest Price (24h): $\(crypto.high24h?.formatted() ?? "N/A")")
                    .font(.headline)
                
                // Lowest Price
                Text("Lowest Price (24h): $\(crypto.low24h?.formatted() ?? "N/A")")
                    .font(.headline)
                
                // Price Change (24h)
                Text("Price Change (24h): \(crypto.priceChange24h?.formatted() ?? "N/A")")
                    .font(.headline)
                    .foregroundColor(crypto.priceChange24h ?? 0 >= 0 ? .green : .red)
                
                // Market Cap
                Text("Market Cap: $\(crypto.marketCap?.formatted() ?? "N/A")")
                    .font(.headline)

                Spacer()
            }
            .padding()
        }
        .navigationTitle(crypto.name ?? "Crypto Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    @Namespace var animation // Declare the Namespace

    return DetailsCryptoView(crypto: Crypto(id: "1", symbol: "btc", name: "Bitcoin", imageURL: "https://coin-images.coingecko.com/coins/images/1/large/bitcoin.png?1696501400", marketCapRank: 1, currentPrice: 67342, marketCap: 1331206384537, totalVolume: 36770950539, high24h: 67941, low24h: 66669, priceChange24h: -238.7735073662334, lastUpdated: Date(), marketCapChange24h: -4781756194.043213, marketCapChangePercentage24h: -0.35792, totalSupply: 21000000.0, maxSupply: 21000000.0, ath: 73738.0, athChangePercentage: -8.6, athDate: Date(), atl: 67.81, atlChangePercentage: 99197.47108, atlDate: Date(), isFavorite: false), animation: animation)
}
