//
//  DetailsCryptoView.swift
//  CryptoApp
//
//  Created by Aleksandr Morozov on 25/10/24.
//

import SwiftUI

struct DetailsCryptoView: View {
    
    @EnvironmentObject var viewModel: CryptoViewModel
    @Environment(\.colorScheme) var colorScheme

    @Binding var crypto: Crypto
    
    
    
    
    var animation: Namespace.ID
    @State private var shimmer: Bool = true
    @State private var isImageLoaded: Bool = false

    @State private var isAnimatingHeart: Bool = false
    @State private var isFavorite = false


    var body: some View {
        
        VStack(spacing: 5){
            
            // Header
            VStack(spacing: 0) {
                
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 4)
                    .padding(.bottom, 10)
                
                // Name and Image
                VStack {
                    
                    
                    HStack{
                        
                        // Image
                        AsyncImage(url: URL(string: crypto.imageURL ?? "")) { phase in
                            
                            switch phase {
                            case .empty:
                                // Loading state with redacted effect
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 70, height: 70)
                                    .redacted(reason: .placeholder)
                                    .opacity(shimmer ? 0.3 : 1.0) // Shimmering effect
                                    .onAppear {
                                        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                                            shimmer.toggle()
                                        }
                                    }
                                    .onAppear {
                                        withAnimation{
                                            isImageLoaded = false
                                        }
                                    }
                                
                            case .success(let image):
                                // Loaded image successfully
                                ZStack{
                                    if isImageLoaded {
                                        image.resizable()
                                            .scaledToFit()
                                            .clipShape(Circle())
                                            .frame(width: 70, height: 70)
                                            .opacity(isImageLoaded ? 1 : 0)
                                            .animation(.spring(), value: isImageLoaded)
                                            .transition(.blurReplace)
                                        
                                    } else {
                                        Circle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 70, height: 70)
                                            .redacted(reason: .placeholder)
                                            .opacity(shimmer ? 0.3 : 1.0) // Shimmering effect
                                            .onAppear {
                                                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                                                    shimmer.toggle()
                                                }
                                            }
                                            .transition(.blurReplace)
                                    }
                                }
                                .onAppear {
                                    withAnimation{
                                        isImageLoaded = true
                                    }
                                }
                                
                                
                            case .failure:
                                Circle()
                                    .fill(Color.gray.opacity(0.5))
                                    .frame(width: 40, height: 40)
                                    .transition(.blurReplace)
                                    .transition(.opacity.animation(.easeIn(duration: 0.3)))
                                    .overlay(
                                        Text(crypto.symbol?.uppercased() ?? "")
                                            .font(.caption2)
                                            .bold()
                                            .foregroundColor(.gray)
                                    )
                                
                            @unknown default:
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 40, height: 40)
                                    .redacted(reason: .placeholder)
                            }
                        }
                        
                        Spacer()
                        
                        
                        // Favorite Button
                        Button(action: {
                            
                            withAnimation {
                                    isAnimatingHeart = true
                                    isFavorite.toggle()

                                    
                                    Task {
                                        await viewModel.toggleFavorite(for: crypto)
                                        // Update the binding after the ViewModel update
                                        if let updatedCrypto = viewModel.cryptos.first(where: { $0.id == crypto.id }) {
                                            crypto = updatedCrypto
                                        }
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        isAnimatingHeart = false
                                    }
                                }
                            
                        }) {
                            Image(systemName: "heart.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 23, height: 23)
                                .foregroundColor(crypto.isFavorite ? .pink : .gray.opacity(0.3))
                                .font(.headline)
                                .padding()
                                .rotationEffect(.degrees(isAnimatingHeart ? 15 : 0))
                                .scaleEffect(isAnimatingHeart ? 1.5 : 1.0)
                                .animation(.snappy(duration: 0.5), value: isAnimatingHeart)
                        }
                        
                    }
                    
                
                    HStack(alignment: .center) {
                        
                        
                        Text(crypto.name ?? "Unknown")
                            .font(.largeTitle)
                            .bold()
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            // Conditional arrow based on value
                            Image(systemName: (crypto.marketCapChangePercentage24h ?? 0) < 0 ? "arrow.down" : "arrow.up")
                                .foregroundColor((crypto.marketCapChangePercentage24h ?? 0) < 0 ? .red : .green)
                                .bold()
                            
                            // Market cap percentage change with color formatting
                            Text(String(format: "%.3f", abs(crypto.marketCapChangePercentage24h ?? 0)))
                                .bold()
                                .font(.title2)
                                .foregroundColor((crypto.marketCapChangePercentage24h ?? 0) < 0 ? .red : .green)
                            
                            Text("%")
                                .bold()
                                .font(.title2)
                                .foregroundColor((crypto.marketCapChangePercentage24h ?? 0) < 0 ? .red : .green)
                        }
                        .offset(y: 3)
                    }
                    
                }
                
            }
            .padding(.bottom, 20)
            
            
            // Body
            VStack{
                
                VStack(spacing: 10){
                    
                    //Total Volume
                    HStack {
                        Image(systemName: "chart.bar")
                            .foregroundColor(.gray)
                            .bold()
                            .font(.caption)
                        
                        Text("Total Volume")
                            .foregroundColor(.gray)
                            .font(.headline)
                        
                        Spacer()
                        
                        Text(abbreviateNumber(crypto.totalVolume))
                            .font(.headline)
                            .bold()
                    }
                    
                    //Last Updated
                    HStack {
                        
                        Image(systemName: "calendar")
                            .foregroundColor(.gray)
                            .bold()
                            .font(.caption)
                        
                        Text("Last Updated")
                            .foregroundColor(.gray)
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("\(formatLastUpdatedDate(crypto.lastUpdated))")
                            .font(.headline)
                            .bold()
                    }
                    
                }
                .padding(.bottom, 10)


                ZStack{
                    Divider()
                        .overlay(
                            Text("STATS")
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                                .bold()
                                .background(
                                    Rectangle()
                                        .foregroundColor(colorScheme == .light ? .white : .black)
                                )
                        )
                }
                
                HStack{
                    Spacer()

                    //Market Rank
                    ZStack{
                        
                        VStack{
                            Text("Rank")
                                .foregroundColor(.gray)
                                .bold()
                            
                            HStack(spacing: 0){
                                Text("#")
                                    .font(.caption)
                                    .offset(y: -2)
                                Text(String(format: "%.0f", crypto.marketCapRank ?? 1))
                                    .bold()
                            }

                        }
                        Image(colorScheme == .light ? "laurel-lightmode" : "laurel-darkmode")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120)
                    }
                    
                    Spacer()
                    // MarketCap
                    VStack{
                        Text("Market Cap")
                            .foregroundColor(.gray)
                            .bold()
                        
                        Text(abbreviateNumber(crypto.marketCap))
                            .bold()
                    }
                    Spacer()
                    
                }
                
                ZStack{
                    Divider()
                        .overlay(
                            Text("24 HRS")
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                                .bold()
                                .background(
                                    Rectangle()
                                        .foregroundColor(colorScheme == .light ? .white : .black)
                                )
                        )
                }
                    .padding(.bottom, 10)

                VStack(spacing: 10){
                    
                    HStack {
                        
                        Image(systemName: "dollarsign.arrow.trianglehead.counterclockwise.rotate.90")
                            .foregroundColor(.gray)
                            .bold()
                            .font(.caption)
                        
                        Text("Price Change:")
                            .foregroundColor(.gray)
                            .font(.headline)
                        
                        Spacer()
                        
                        Text(crypto.priceChange24h != nil ? String(format: "%.2f", crypto.priceChange24h!) : "N/A")
                            .font(.headline)
                            .foregroundColor(crypto.priceChange24h ?? 0 >= 0 ? .green : .red)
                    }

                    HStack {
                        
                        Image(systemName: "arrow.up")
                            .foregroundColor(.gray)
                            .bold()
                            .font(.caption)
                        
                        Text("Highest Price:")
                            .foregroundColor(.gray)
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("\(crypto.high24h?.formatted() ?? "N/A")")
                            .font(.headline)
                    }
                    
                    HStack {
                        
                        Image(systemName: "arrow.down")
                            .foregroundColor(.gray)
                            .bold()
                            .font(.caption)
                        
                        Text("Lowest Price:")
                            .foregroundColor(.gray)
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("$\(crypto.low24h?.formatted() ?? "N/A")")
                            .font(.headline)
                    }
                }
            }
            
            Spacer()
            
            VStack(spacing: 5){
                HStack{
                    Image(systemName: "network")
                        .padding(.leading, 1)
                    
                    Spacer()
                }
                
                Text("Data provided by CoinGecko API. Information may not be up-to-date or accurate. Use for informational purposes only.")
            }
            .font(.caption)
            .foregroundColor(.gray.opacity(0.7))

            
        }
        .padding(.horizontal, 30)
        .navigationBarHidden(true)
        .onAppear{
            //isFavorite = crypto.isFavorite
        }
    }
    
    // Helper function to format large numbers
    private func abbreviateNumber(_ number: Double?) -> String {
        guard let number = number else { return "N/A" }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        
        switch abs(number) {
        case 1_000_000_000_000...:
            let trillions = number / 1_000_000_000_000
            return "$" + (formatter.string(from: NSNumber(value: trillions)) ?? "") + "T"
            
        case 1_000_000_000...:
            let billions = number / 1_000_000_000
            return "$" + (formatter.string(from: NSNumber(value: billions)) ?? "") + "B"
            
        case 1_000_000...:
            let millions = number / 1_000_000
            return "$" + (formatter.string(from: NSNumber(value: millions)) ?? "") + "M"
            
        case 1_000...:
            let thousands = number / 1_000
            return "$" + (formatter.string(from: NSNumber(value: thousands)) ?? "") + "K"
            
        default:
            return "$" + (formatter.string(from: NSNumber(value: number)) ?? "")
        }
    }
    
    // Helper function to format last updated date
    func formatLastUpdatedDate(_ dateString: String?) -> String {
        guard let dateString = dateString else { return "N/A" }
        
        // Parse the ISO 8601 string to a Date object in UTC
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = isoFormatter.date(from: dateString) else {
            return "Invalid date"
        }
        
        // Format the date to the local time zone and desired format
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm" // Custom format: day/month/year hour:minute
        formatter.timeZone = .current // Local time zone
        return formatter.string(from: date)
    }
}

#Preview {
    
    @Previewable @Namespace var animation
    
    // Create a sample Crypto object with `@State` to allow passing it as a binding
    var sampleCrypto = Crypto(
        id: "1",
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
        marketCapChangePercentage24h: -0.35792,
        totalSupply: 21000000.0,
        maxSupply: 21000000.0,
        ath: 73738.0,
        athChangePercentage: -8.6,
        athDate: Date(),
        atl: 67.81,
        atlChangePercentage: 99197.47108,
        atlDate: Date(),
        isFavorite: false
    )

    DetailsCryptoView(crypto: .constant(sampleCrypto), animation: animation)
        .environmentObject(CryptoViewModel())
}
