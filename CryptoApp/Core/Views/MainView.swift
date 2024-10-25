//
//  MainView .swift
//  CryptoApp
//
//  Created by Aleksandr Morozov on 22/10/24.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = CryptoViewModel()
    
    @State private var searchText: String = ""
    
    
    //UI
    @Namespace private var animation

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Search Cryptos", text: $searchText)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.primary.opacity(0.1)))
                    .padding(.horizontal, 20)

                switch viewModel.state {
                case .loading:
                    ProgressView("Loading Cryptos...")
                        .scaleEffect(1.5, anchor: .center)
                    
                case .success:
                    ScrollView {
                        LazyVStack {
                            ForEach(viewModel.filteredCryptos) { crypto in
                                NavigationLink(destination: {
                                    DetailsCryptoView(crypto: crypto, animation: animation)
                                        .navigationTransition(.zoom(sourceID: crypto.id, in: animation))
                                }){
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


                case .error(let error):
                    Text("Failed to load cryptos: \(error.localizedDescription)")
                        .foregroundColor(.red)
                        .padding()
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
}

#Preview {
    MainView()
}
