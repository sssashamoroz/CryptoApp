//
//  CryptoRowView.swift
//  CryptoApp
//
//  Created by Aleksandr Morozov on 22/10/24.
//

import SwiftUI

struct CryptoRowView: View {
    
    let crypto: Crypto
    
    
    @State private var isImageLoaded = false
    @State private var shimmer = false  // Controls shimmer animation
    @State private var imageURL: URL? // Dynamic URL with cache-busting
    
    @State private var loadAttempts = 0 // Track image load attempts
    
    init(crypto: Crypto) {
        self.crypto = crypto
        _imageURL = State(initialValue: URL(string: crypto.imageURL ?? ""))
    }
    
    var body: some View {
        HStack {
            // Crypto Image (Load asynchronously)
            AsyncImage(url: imageURL) { phase in

                switch phase {
                case .empty:
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .redacted(reason: .placeholder)
                        .opacity(shimmer ? 0.3 : 1.0)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                                shimmer.toggle()
                            }
                        }
                    
                case .success(let image):
                    image.resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(width: 40, height: 40)
                        .opacity(isImageLoaded ? 1 : 0)
                        .animation(.spring(), value: isImageLoaded)
                        .onAppear { isImageLoaded = true }
                    
                case .failure:
                    Circle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(crypto.symbol?.uppercased() ?? "")
                                .font(.caption2)
                                .bold()
                                .foregroundColor(.gray)
                        )
                        .onAppear {
                            if loadAttempts < 5 { // Limit retry attempts
                                loadAttempts += 1
                                // Retry with a cache-busting query string
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    imageURL = URL(string: "\(crypto.imageURL ?? "")?\(UUID().uuidString)")
                                }
                            }
                        }
                    
                @unknown default:
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .redacted(reason: .placeholder)
                }
            }
            // Crypto Name and Symbol
            VStack(alignment: .leading) {
                Text(crypto.name ?? "")
                    .font(.headline)
                Text(crypto.symbol?.uppercased() ?? "")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing){
                HStack(spacing: 0) {
                    let currentPrice = crypto.currentPrice ?? 0.0
                    Text(formattedAmount(currentPrice))
                        .font(.headline)

                    Text("$")
                        .foregroundColor(.gray)
                        .font(.headline)
                }

                HStack(spacing: 0) {
                    let percentageChange = crypto.marketCapChangePercentage24h ?? 0.0
                    Text(String(format: "%.1f", percentageChange.isNaN ? 0.0 : percentageChange))
                        .foregroundColor(.gray)
                    Text("%")
                        .foregroundColor(.gray)
                }
            }
            
        }
        .padding()
    }
    
    
    // Helper function to format only the amount part
    private func formattedAmount(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: price)) ?? "0.00"
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
        lastUpdated: "2024-10-26T02:27:56.575Z",
        marketCapChange24h: -4781756194.043213,
        marketCapChangePercentage24h: -0.44677,
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
