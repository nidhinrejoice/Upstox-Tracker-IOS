//
//  LoginUseCase.swift
//  Upstox Tracker
//
//  Created by Nidhin Rejoice on 08/07/24.
//

import Foundation

protocol AuthRepository {
    func getAccessToken(authCode: String, completion: @escaping (Result<String, Error>) -> Void)
}

class LoginUseCase {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    func execute(authCode: String, completion: @escaping (Result<String, Error>) -> Void) {
        authRepository.getAccessToken(authCode: authCode, completion: completion)
    }
}

class GenerateTokenUseCase {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    func execute(authCode: String, completion: @escaping (Result<String, Error>) -> Void) {
        authRepository.getAccessToken(authCode: authCode, completion: completion)
    }
}
class SortHoldingsUseCase {
    func execute(sortBy : LoginViewModel.SortOption,sortAscending :  Bool, holdings:[Stock]) -> [Stock] {
        var newList = holdings
        switch sortBy {
        case .name:
            newList.sort {
                if(!sortAscending){
                    $0.companyName < $1.companyName
                }else{
                    $0.companyName > $1.companyName
                }
            }
        case .pnl:
            newList.sort {
                if(!sortAscending){
                    $0.pnl > $1.pnl
                }else{
                    $0.pnl < $1.pnl
                }
            }
        case .investment:
            newList.sort {
                if(!sortAscending){
                    $0.averagePrice*Double($0.quantity) > $1.averagePrice*Double($1.quantity)
                }else{
                    $0.averagePrice*Double($0.quantity) < $1.averagePrice*Double($1.quantity)
                }
            }
        case .current:
            
            if(!sortAscending){
                newList.sort { $0.lastPrice*Double($0.quantity) > $1.lastPrice*Double($1.quantity)  }
            }else{
                newList.sort { $0.lastPrice*Double($0.quantity) < $1.lastPrice*Double($1.quantity)  }
            }
        case .percent:
            
            if(!sortAscending){
                newList.sort {
                    ($0.lastPrice/$0.averagePrice)*100 >  ($1.lastPrice/$1.averagePrice)*100
                }
            }else{
                newList.sort {
                    ($0.lastPrice/$0.averagePrice)*100 <  ($1.lastPrice/$1.averagePrice)*100
                }
            }
        case .dailyPnl:
            if(!sortAscending){
                newList.sort { $0.dayChange > $1.dayChange }
            }else{
                newList.sort { $0.dayChange < $1.dayChange }
            }
        case .dailyPercent:
            if(!sortAscending){
                newList.sort { $0.dayChangePercentage > $1.dayChangePercentage }
            }else{
                newList.sort { $0.dayChangePercentage < $1.dayChangePercentage }
            }
        }
        return newList
    }
}


protocol FetchStockHoldingsUseCase {
    typealias Completion = (Result<[Stock], Error>) -> Void
    func execute(completion: @escaping Completion)
}

class FetchStockHoldingsUseCaseImpl: FetchStockHoldingsUseCase {
    private let apiService: APIService
    
    init(apiService: APIService) {
        self.apiService = apiService
    }
    
    func execute(completion: @escaping Completion) {
        let endpoint = "https://api.upstox.com/v2/portfolio/long-term-holdings"
        
        // Set headers
        let headers = [
            "Authorization": "Bearer \(TokenManager.shared.accessToken ?? "")",
            "Accept": "application/json"
        ]
        
        // Make API call
        apiService.fetchData(from: endpoint, headers: headers) { result in
            switch result {
            case .success(let data):
                do {
                    let holdings = try JSONDecoder().decode(HoldingsResponse.self, from: data)
                    
                    completion(.success(holdings.data.filter{$0.averagePrice > 0}.sorted{$0.companyName<$1.companyName}))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}


protocol FetchProfitLossReportUseCase {
    typealias Completion = (Result<[AggregatedProfitLoss], Error>) -> Void
    func execute(financialYear : String, completion: @escaping Completion)
}
class FetchProfitLossReportUseCaseImpl : FetchProfitLossReportUseCase {
    
    private let apiService: APIService
    
    init(apiService: APIService) {
        self.apiService = apiService
    }
    
    func execute(financialYear : String, completion: @escaping Completion) {
        
        let endpoint = "https://api.upstox.com/v2/trade/profit-loss/data?segment=EQ&financial_year=\(financialYear)&page_number=\(1)&page_size=\(500)"
        
        // Set headers
        let headers = [
            "Authorization": "Bearer \(TokenManager.shared.accessToken ?? "")",
            "Accept": "application/json"
        ]
        
        // Make API call
        apiService.fetchData(from: endpoint, headers: headers) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(ProfitLossResponse.self, from: data)
                    let aggregatedData = self.aggregateProfitLossData(response.data)
                    completion(.success(aggregatedData.sorted{$0.scriptName<$1.scriptName}))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func aggregateProfitLossData(_ trades: [ProfitLoss]) -> [AggregatedProfitLoss] {
           var aggregatedData: [String: AggregatedProfitLoss] = [:]
           
           for trade in trades {
               var scripName = trade.scripName
               if(trade.scripName.isEmpty){
                   scripName = "N/A"
               }
               if var existing = aggregatedData[scripName] {
                   existing.totalProfit += (trade.sellAmount - trade.buyAmount)
                   existing.profitReport.append(trade)
                   aggregatedData[scripName] = existing
               } else {
                   var pl = AggregatedProfitLoss(
                    scriptName: scripName,
                    totalProfit: (trade.sellAmount - trade.buyAmount),
                    profitReport: [trade]
                )
                   aggregatedData[scripName] = pl
               }
           }
           
           return Array(aggregatedData.values)
       }
}
