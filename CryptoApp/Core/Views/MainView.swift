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
                Spacer()
                    .frame(height: 20)
                
                HStack(alignment: .bottom){
                    Text("Cryptos")
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    
                    
                    HStack{
                        Image(systemName: "arrow.counterclockwise")
                            .font(.caption2)
                            .bold()
                            .foregroundColor(.gray)
                        
                        Text("\(formattedLastRefresh)")
                             .font(.caption)
                             .bold()
                             .foregroundColor(.gray)
                    }
                    
                    if !viewModel.isOnline {
                        HStack{
                            Text("Offline")
                                .font(.caption)
                                .bold()
                                .foregroundColor(.gray)
                                .transition(.opacity)
                            
                            Circle()
                                .fill(Color.red.opacity(0.8))
                                .frame(width: 5)
                                .offset(x: -5, y: -2)
                        }
                        .transition(.opacity.animation(.snappy.delay(1)))
                    }
    

                }
                .padding(.horizontal, 20)

                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search Cryptos", text: $viewModel.searchText)
                        .focused($isSearchFocused)
                        .accentColor(.pink)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.gray.opacity(0.15)))
                .padding(.horizontal, 20)
                
                switch viewModel.state {
                case .loading:
                    ScrollView {
                        LazyVStack(spacing:5) {
                            ForEach(0..<10) { _ in
                                CryptoRowView(crypto: $placeholderCrypto)
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
                                    if let index = viewModel.filteredCryptos.firstIndex(where: { $0.id == crypto.id }) {
                                        CryptoRowView(crypto:  $viewModel.filteredCryptos[index])
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .matchedTransitionSource(id: crypto.id, in: animation)
                            }
                        }
                    }
                    .safeAreaPadding(.top, 10)
                    .safeAreaPadding(.bottom, 30)
                    .refreshable {
                        if viewModel.isOnline {
                            await viewModel.refreshData()
                        }
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
            }
            .task(id: viewModel.state) {
                if case .loading = viewModel.state {
                    await viewModel.fetchData()

                }
            }
            .onAppear {
                viewModel.filterCryptos()
                viewModel.resetSearchText()
            }
        }

    }
    
    var formattedLastRefresh: String {
        guard let lastRefresh = viewModel.lastRefresh else { return "N/A" }
        
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "dd MMM, HH:mm"
        return formatter.string(from: lastRefresh)
    }
    
    @State var placeholderCrypto = Crypto(
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
}



#Preview {
    
    let previewViewModel = CryptoViewModel()

    return MainView()
        .environmentObject(previewViewModel)
}

