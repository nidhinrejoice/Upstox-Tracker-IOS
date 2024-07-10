//
//  ProfitLossViewModel.swift
//  Upstox Tracker
//
//  Created by Nidhin Rejoice on 09/07/24.
//

import Foundation
class ProfitLossViewModel: ObservableObject {
    private let fetchProfitLossReportUseCase : FetchProfitLossReportUseCase
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var profitLossReport: [AggregatedProfitLoss] = []
    @Published var error: Error?
    @Published var aggregateProfitLoss : AggregatedProfitLoss?
    @Published var orderHistoryShown = false
    init(fetchProfitLossReportUseCase: FetchProfitLossReportUseCase) {
        self.fetchProfitLossReportUseCase = fetchProfitLossReportUseCase
    }
    
    @Published var sortBy: LoginViewModel.SortOption = .name
    @Published var sortAscending  = false
    
    func sortStocks(sortBy : LoginViewModel.SortOption) {
        
//        if(sortBy == self.sortBy){
//            sortAscending = !sortAscending
//        }
        
        self.sortBy = sortBy
        //        stocks = sortHoldingsUseCase.execute(sortBy: sortBy, sortAscending: sortAscending, holdings: stocks)
        
        switch (sortBy){
            
        case .name:
            return profitLossReport.sort{
                $0.scriptName < $1.scriptName
            }
        case .pnl:
            return profitLossReport.sort{
                $0.totalProfit > $1.totalProfit
            }
            
        default :
            return 
        }
        
    }
    
    func fetchProfitReport(financialYear  :String){
        DispatchQueue.main.async {
            self.isLoading = false 
        }
        var finYear = financialYear
        finYear.replace("-", with:"")
        finYear.replace("20",with: "")
        fetchProfitLossReportUseCase.execute(financialYear: finYear){ result in
            self.sortBy = .name
            switch result {
            case .success(let profitLossReport):
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.profitLossReport = profitLossReport
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.error = error
                    self.isLoading = false
                }
            }
            
        }
    }
    
    func showOrderHistory(scriptName : String){
        orderHistoryShown = true
        aggregateProfitLoss = profitLossReport.first(where: {$0.scriptName == scriptName})
    }
}
