//
//  MainView .swift
//  CryptoApp
//
//  Created by Aleksandr Morozov on 22/10/24.
//

import SwiftUI

struct MainView: View {
    
    @EnvironmentObject var viewModel: CryptoViewModel
    @Environment(\.colorScheme) var colorScheme


    @State private var searchText: String = ""

    @State private var isSearching: Bool = false
    @FocusState private var isSearchFocused: Bool
    @State private var isSearchActive: Bool = false
    
    //UI
    @Namespace private var animation
    @State private var shimmer = false


    var body: some View {
        NavigationStack {
            
            VStack {
                
                TextField("Search Cryptos", text: $searchText)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.gray.opacity(0.15)))
                    .padding(.horizontal, 20)
                    .focused($isSearchFocused)
                    .onChange(of: searchText) {
                        viewModel.search(by: searchText)
                    }
                    .onChange(of: isSearchFocused) {
                        withAnimation{
                            isSearchActive = isSearchFocused
                        }
                    }
                
                if isSearchActive {
                    switch viewModel.state {
                    case .loading:
                        ScrollView {
                            LazyVStack(spacing:5) {
                                ForEach(0..<10) { _ in
                                    CryptoRowView(crypto: placeholderCrypto)
                                        .redacted(reason: .placeholder)
                                        .opacity(shimmer ? 0.3 : 1.0) // Shimmering effect
                                }
                            }
                            .onAppear {
                                // Trigger shimmer animation
                                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                                    shimmer.toggle()
                                }
                            }
                        }
                        
                    case .success:
                        ScrollView {
                            LazyVStack {
                                ForEach(viewModel.filteredCryptos) { crypto in
                                    NavigationLink(destination: {
                                        if let index = viewModel.filteredCryptos.firstIndex(where: { $0.id == crypto.id }) {
                                            DetailsCryptoView(crypto: $viewModel.filteredCryptos[index], animation: animation)
                                                .navigationTransition(.zoom(sourceID: crypto.id, in: animation))
                                        }
                                    }) {
                                        CryptoRowView(crypto: crypto)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .matchedTransitionSource(id: crypto.id, in: animation)
                                }
                            }
                        }
                        .refreshable {
                            await viewModel.refreshData()
                        }
                        .padding(.horizontal, 10)
                        .mask(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: .clear, location: 0),
                                    .init(color: .black.opacity(1), location: 0.03),
                                    .init(color: .black, location: 0.5),
                                    .init(color: .black.opacity(0.8), location: 0.9),
                                    .init(color: .clear, location: 1)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        
                        
                    case .error(let error):
                        Text("Failed to load cryptos: \(error.localizedDescription)")
                            .foregroundColor(.red)
                            .padding()
                    }
                } else {
                    ScrollView {
                        if !viewModel.favorites.isEmpty {
                            LazyVStack(alignment: .leading) {
                                
                                HStack(alignment: .bottom){
                                    Text("Favorites")
                                        .font(.title2).bold()
                                        .padding(.leading)
                                    
                                    Spacer()
                                    
                        
                                    if let lastUpdated = viewModel.lastRefresh {
                                        
                                            Image(systemName: "arrow.clockwise")
                                                .font(.footnote)
                                                .bold()
                                                .foregroundColor(.gray.opacity(0.5))
                                            
                                            Text(formatLastUpdatedDate(lastUpdated))
                                                .font(.footnote)
                                                .bold()
                                                .foregroundColor(.gray.opacity(0.5))
                                                .padding(.trailing)
                                        

                                    }
                                }

                                
                                LazyVStack {
                                    ForEach(viewModel.favorites) { crypto in
                                        NavigationLink(destination: {
                                            if let index = viewModel.cryptos.firstIndex(where: { $0.id == crypto.id }) {
                                                DetailsCryptoView(crypto: $viewModel.cryptos[index], animation: animation)
                                                    .navigationTransition(.zoom(sourceID: crypto.id, in: animation))
                                            }
                                        }) {
                                            CryptoRowView(crypto: crypto)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .matchedTransitionSource(id: crypto.id, in: animation)
                                    }
                                }
                                .padding(.bottom, 10)
                            }
                        } else {
                            // Display a placeholder if no favorites
                            ZStack {
                                VStack(alignment: .leading) {
                                    
                                    HStack{
                                        Text("Favorites")
                                            .font(.title2).bold()
                                            .padding(.leading)
                        
                                    }

                                    
                                    // Display redacted CryptoRowView items in a LazyVStack
                                    LazyVStack(spacing: -13){
                                        ForEach(0..<4) { _ in
                                            CryptoRowView(crypto: placeholderCrypto) // Redacted CryptoRowView
                                                .redacted(reason: .placeholder)
                                                .opacity(0.3)
                                        }
                                    }
                                    .mask(
                                        LinearGradient(
                                            gradient: Gradient(stops: [
                                                .init(color: .clear, location: 0),
                                                .init(color: .black.opacity(1), location: 0.03),
                                                .init(color: .black, location: 0.5),
                                                .init(color: .clear, location: 1)
                                            ]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .padding(.horizontal)
                                    .padding(.bottom, 10)
                                }
                                
                                // Overlay message
                                VStack {
                                    Text("No favorites added yet 😞")
                                        .foregroundColor(.gray)
                                        .font(.headline)
                                    
                                    Text("Search for a crypto to add it to your favorites") .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .font(.subheadline)
                                        .padding(.horizontal)
                                }
                                .padding()
                                .background(
                                    Capsule()
                                        .foregroundColor(colorScheme == .light ? .white : .black)
                                        .blur(radius: 10)
                                )
                            }
                            .padding(.vertical, 10)

 
                        }
                    }
                    .refreshable {
                        await viewModel.refreshData()
                    }
                    .safeAreaPadding(.top, 10)
                    .padding(.horizontal, 10)
                    .mask(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .clear, location: 0),
                                .init(color: .black.opacity(1), location: 0.03),
                                .init(color: .black, location: 0.5),
                                .init(color: .black.opacity(0.8), location: 0.9),
                                .init(color: .clear, location: 1)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .transition(.opacity)
                }
            }
            .navigationTitle("Cryptos")
            .task(id: viewModel.state) {
                if case .loading = viewModel.state {
                    await viewModel.fetchData()
                }
            }
        }

    }
    
    func formatLastUpdatedDate(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }
        
        let formatter = DateFormatter()
        formatter.locale = Locale.current // Uses device's locale
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            // If the date is today, display "Today, HH:mm"
            formatter.dateFormat = "HH:mm"
            return "Today, \(formatter.string(from: date))"
        } else {
            // If not today, display "dd MMM, HH:mm"
            formatter.dateFormat = "dd MMM, HH:mm"
            return formatter.string(from: date)
        }
    }
}

let placeholderCrypto = Crypto(
    id: "placeholder",
    symbol: "BTC",
    name: "Placeholder",
    imageURL: "https://coin-images.coingecko.com/coins/images/325/large/Tether.png?1696501661",
    marketCapRank: 1,
    currentPrice: 67342,
    marketCap: 1331206384537,
    totalVolume: 36770950539,
    high24h: 67941,
    low24h: 66669,
    priceChange24h: -238.77,
    lastUpdated: "2024-10-26T02:27:56.575Z",
    marketCapChange24h: -4781756194.04,
    marketCapChangePercentage24h: -0.35,
    totalSupply: 21000000.0,
    maxSupply: 21000000.0,
    ath: 73738.0,
    athChangePercentage: -8.6,
    athDate: Date(),
    atl: 67.81,
    atlChangePercentage: 99197.47,
    atlDate: Date()
)

#Preview {
    
    let previewViewModel = CryptoViewModel()

    return MainView()
        .environmentObject(previewViewModel)
}

