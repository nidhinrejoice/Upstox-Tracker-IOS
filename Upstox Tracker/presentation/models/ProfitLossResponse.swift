//
//  ProfitLossResponse.swift
//  Upstox Tracker
//
//  Created by Nidhin Rejoice on 09/07/24.
//

import Foundation

struct ProfitLossResponse: Codable {
    let status: String
    let data: [ProfitLoss]
    let metadata: Metadata
}

struct ProfitLoss: Identifiable, Codable {
    let id = UUID()
    let quantity: Int
    let isin: String
    let scripName: String
    let tradeType: String
    let buyDate: String
    let buyAverage: Double
    let sellDate: String
    let sellAverage: Double
    let buyAmount: Double
    let sellAmount: Double
    
    
    enum CodingKeys: String, CodingKey {
        case isin, quantity
        case scripName = "scrip_name"
        case tradeType = "trade_type"
        case buyDate = "buy_date"
        case buyAverage = "buy_average"
        case sellDate = "sell_date"
        case sellAverage = "sell_average"
        case buyAmount = "buy_amount"
        case sellAmount = "sell_amount"
    }
}

struct Metadata: Codable {
    let page: Page
}

struct Page: Codable {
    let pageNumber: Int
    let pageSize: Int
    
    enum CodingKeys: String, CodingKey {
        case pageNumber = "page_number"
        case pageSize = "page_size"
    }
}
