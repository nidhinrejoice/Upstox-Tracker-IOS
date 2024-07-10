//
//  UpstoxApp.swift
//  Upstox Tracker
//
//  Created by Nidhin Rejoice on 08/07/24.
//
import SwiftUI

@main
struct UpstoxApp: App {
    var body: some Scene {
        WindowGroup {
            let authRepository = AuthRepositoryImpl()
            let sortHoldings = SortHoldingsUseCase()
            let loginUseCase = LoginUseCase(authRepository: authRepository)
            let generateTokenUseCase = GenerateTokenUseCase(authRepository: authRepository)
            let fetchHoldingsUseCase = FetchStockHoldingsUseCaseImpl(apiService: APIServiceImpl())
            let fetchProfitLossReportUseCase = FetchProfitLossReportUseCaseImpl(apiService: APIServiceImpl())
            let loginViewModel = LoginViewModel(loginUseCase: loginUseCase, generateTokenUseCase: generateTokenUseCase, fetchHoldingsUseCase: fetchHoldingsUseCase, sortHoldingsUseCase: sortHoldings)
            let profitLossViewModel = ProfitLossViewModel(fetchProfitLossReportUseCase: fetchProfitLossReportUseCase)
            ContentView(viewModel: loginViewModel, profitLossViewModel : profitLossViewModel)
        }
    }
}
