//
//  ContentView.swift
//  Upstox Tracker
//
//  Created by Nidhin Rejoice on 08/07/24.
//

import SwiftUI

extension Color {
    static let deepGreen = Color(red: 0.0, green: 100.0 / 255.0, blue: 0.0) // Adjust the RGB values as needed
}
struct ContentView: View {
    @StateObject private var viewModel: LoginViewModel
    @StateObject private var profitLossViewModel : ProfitLossViewModel
    
    init(viewModel: LoginViewModel, profitLossViewModel: ProfitLossViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _profitLossViewModel = StateObject(wrappedValue: profitLossViewModel)
    }
    
    var body: some View {
        TabView {
            HoldingsView(viewModel : viewModel)
                .tabItem {
                    Label("Portfolio", systemImage: "list.dash")
                }
            ProfitLossReportView(viewModel : profitLossViewModel)
                .tabItem {
                    Label("Reports", systemImage: "newspaper")
                }
        }.tabViewStyle(DefaultTabViewStyle())
    }
}
