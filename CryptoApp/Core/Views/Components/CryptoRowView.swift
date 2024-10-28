//
//  CryptoRowView.swift
//  CryptoApp
//
//  Created by Aleksandr Morozov on 22/10/24.
//

import SwiftUI

struct CryptoRowView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var crypto: Crypto
    
    @State private var isImageLoaded = false
    @State private var shimmer = false  // Controls shimmer animation
    @State private var imageURL: URL?
    
    var body: some View {
        HStack {
            ZStack {
                // Crypto Image (Load asynchronously)
                if let url = imageURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            shimmerPlaceholder()
                        case .success(let image):
                            imageView(image)
                        case .failure:
                            failedImageView()
                        @unknown default:
                            shimmerPlaceholder()
                        }
                    }
                } else {
                    shimmerPlaceholder() // Placeholder if imageURL is nil
                }
                
                // Heart Overlay for Favorite Cryptos
                if crypto.isFavorite {
                    favoriteHeartOverlay()
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
            
            VStack(alignment: .trailing) {
                // Display current price
                HStack(spacing: 0) {
                    let currentPrice = crypto.currentPrice ?? 0.0
                    Text(formattedAmount(currentPrice))
                        .font(.headline)
                    Text("$")
                        .foregroundColor(.gray)
                        .font(.headline)
                }
                
                // Display 24-hour change percentage
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
        .onAppear {
            initializeImageURL()
        }
    }
    
    // Helper function to initialize imageURL safely on appear
    private func initializeImageURL() {
        if let validImageURL = crypto.imageURL, !validImageURL.isEmpty {
            imageURL = URL(string: validImageURL)
        } else {
            imageURL = nil
        }
    }
    
    // MARK: - Subviews for Image Placeholders and Overlays
    
    // Placeholder view for shimmer effect
    private func shimmerPlaceholder() -> some View {
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
    }
    
    // Image view for successfully loaded image
    private func imageView(_ image: Image) -> some View {
        image.resizable()
            .scaledToFit()
            .clipShape(Circle())
            .frame(width: 40, height: 40)
            .opacity(isImageLoaded ? 1 : 0)
            .animation(.spring(), value: isImageLoaded)
            .onAppear { isImageLoaded = true }
    }
    
    // Fallback view when image loading fails
    private func failedImageView() -> some View {
        Circle()
            .fill(Color.gray.opacity(0.5))
            .frame(width: 40, height: 40)
            .overlay(
                Text(crypto.symbol?.uppercased() ?? "")
                    .font(.caption2)
                    .bold()
                    .foregroundColor(.gray)
            )
    }
    
    // Heart overlay for favorite crypto
    private func favoriteHeartOverlay() -> some View {
        Image(systemName: "heart.fill")
            .foregroundColor(.pink)
            .font(.caption)
            .background(
                Circle()
                    .fill(colorScheme == .light ? Color.white : Color.black)
                    .frame(width: 18, height: 18)
            )
            .offset(x: 14, y: -14)
    }
    
    // Helper function to format the amount
    private func formattedAmount(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: price)) ?? "0.00"
    }
}
//#Preview {
//    CryptoRowView(crypto: Crypto(
//        id: "bitcoin",
//        symbol: "btc",
//        name: "Bitcoin",
//        imageURL: "https://coin-images.coingecko.com/coins/images/1/large/bitcoin.png?1696501400",
//        marketCapRank: 1,
//        currentPrice: 67342,
//        marketCap: 1331206384537,
//        totalVolume: 36770950539,
//        high24h: 67941,
//        low24h: 66669,
//        priceChange24h: -238.7735073662334,
//        lastUpdated: "2024-10-26T02:27:56.575Z",
//        marketCapChange24h: -4781756194.043213,
//        marketCapChangePercentage24h: -0.44677,
//        totalSupply: 21000000.0,
//        maxSupply: 21000000.0,
//        ath: 73738.0,
//        athChangePercentage: -8.6,
//        athDate: Date(),
//        atl: 67.81,
//        atlChangePercentage: 99197.47108,
//        atlDate: Date()
//    ))
//}
