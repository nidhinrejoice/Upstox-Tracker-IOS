//
//  StockProfitLoss.swift
//  Upstox Tracker
//
//  Created by Nidhin Rejoice on 09/07/24.
//

import Foundation

struct AggregatedProfitLoss : Identifiable, Codable{
    
    let id = UUID()
    let scriptName: String
    var totalProfit: Double
    var profitReport : [ProfitLoss]
}
