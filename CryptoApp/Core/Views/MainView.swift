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
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search Cryptos", text: $searchText, onCommit: {
                    viewModel.search(by: searchText)
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                
                switch viewModel.state {
                case .loading:
                    ProgressView("Loading Cryptos...")
                        .scaleEffect(1.5, anchor: .center)
                    
                case .success:
                    List(viewModel.cryptos) { crypto in
                            CryptoRowView(crypto: crypto)
                    }
                    .refreshable {
                        await viewModel.refreshData()
                    }
                    
                case .error(let error):
                    Text("Failed to load cryptos: \(error.localizedDescription)")
                        .foregroundColor(.red)
                        .padding()
                
                }
            }
            .navigationTitle("Cryptos")
            .onAppear {
                Task {
                    await viewModel.fetchData()
                }
            }
        }
    }
}

#Preview {
    MainView()
}
