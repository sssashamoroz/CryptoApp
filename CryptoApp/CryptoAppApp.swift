//
//  CryptoAppApp.swift
//  CryptoApp
//
//  Created by Aleksandr Morozov on 22/10/24.
//

import SwiftUI

@main
struct CryptoAppApp: App {
    
    @StateObject private var viewModel = CryptoViewModel()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(viewModel)

        }
    }
}
