//
//  LoginViewModel.swift
//  Upstox Tracker
//
//  Created by Nidhin Rejoice on 08/07/24.
//

import Foundation

class LoginViewModel: ObservableObject {
    private let loginUseCase: LoginUseCase
    private let generateTokenUseCase: GenerateTokenUseCase
    private let fetchHoldingsUseCase : FetchStockHoldingsUseCase
    private let sortHoldingsUseCase : SortHoldingsUseCase
    @Published var isLoggedIn = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isShowingWebView = false // State to control WebView presentation
    @Published var stocks: [Stock] = []
    @Published var profitLossReport: [AggregatedProfitLoss] = []
    @Published var error: Error?
    
    init(loginUseCase: LoginUseCase, generateTokenUseCase: GenerateTokenUseCase,fetchHoldingsUseCase : FetchStockHoldingsUseCase, sortHoldingsUseCase : SortHoldingsUseCase) {
        self.loginUseCase = loginUseCase
        self.generateTokenUseCase = generateTokenUseCase
        self.fetchHoldingsUseCase = fetchHoldingsUseCase
        self.sortHoldingsUseCase = sortHoldingsUseCase
        checkAccessToken()
    }
    
    private func checkAccessToken() {
        guard TokenManager.shared.accessToken == nil else {
            self.isLoggedIn = true
            self.isShowingWebView = false
            self.fetchUserHoldings()
            return
        }
        // If no access token, initiate login flow
        self.isShowingWebView = true
    }
    
    func handleAuthCode(_ code: String) {
        loginUseCase.execute(authCode: code) { result in
            switch result {
            case .success(let accessToken):
                self.isShowingWebView = false
                DispatchQueue.main.async {
                    self.isLoggedIn = true
                }
                self.fetchUserHoldings()
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isShowingWebView = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func fetchUserHoldings(){
        isLoading = true
        fetchHoldingsUseCase.execute(){ result in
            
            switch result {
            case .success(let stocks):
                DispatchQueue.main.async {
                    self.stocks = stocks
                    self.isLoading = false
                    self.stocks = self.sortHoldingsUseCase.execute(sortBy: self.sortBy, sortAscending: self.sortAscending, holdings: self.stocks)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isShowingWebView = true
                    self.error = error
                    self.isLoading = false
                }
            }
            
        }
    }
    
    @Published var sortBy: SortOption = .name
    enum SortOption: String, CaseIterable {
        case name = "Name"
        case dailyPnl = "Daily Pnl"
        case pnl = "PNL"
        case dailyPercent = "Daily %"
        case percent = "%age"
        case investment = "Invested"
        case current = "Curr Val."
    }
    @Published var sortAscending  = false
    
    func sortStocks(sortBy : SortOption) {
        
        if(sortBy == self.sortBy){
            sortAscending = !sortAscending
        }
        self.sortBy = sortBy
        stocks = sortHoldingsUseCase.execute(sortBy: sortBy, sortAscending: sortAscending, holdings: stocks) 
         
    }
    
//    func fetchProfitReport(){
//        isLoading = true
//        fetchProfitLossReportUseCase.execute(financialYear: "2324"){ result in
//            
//            switch result {
//            case .success(let profitLossReport):
//                DispatchQueue.main.async {
//                    self.isLoading = false
//                    self.profitLossReport = profitLossReport
//                }
//            case .failure(let error):
//                DispatchQueue.main.async {
//                    self.error = error
//                    self.isLoading = false
//                }
//            }
//            
//        }
//    }
}
