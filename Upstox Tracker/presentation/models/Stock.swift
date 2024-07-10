//
//  Stock.swift
//  Upstox Tracker
//
//  Created by Nidhin Rejoice on 08/07/24.
//

import Foundation

struct Stock: Codable, Identifiable {
    var id = UUID()
    let isin: String
    let cncUsedQuantity: Int  // Using camelCase to match JSON keys
    let collateralType: String
    let companyName: String
    let haircut: Double
    let product: String
    let quantity: Int
    let tradingSymbol: String
    let lastPrice: Double
    let closePrice: Double
    let pnl: Double
    let dayChangePercentage: Double
    let instrumentToken: String
    let averagePrice: Double
    let collateralQuantity: Int
    let collateralUpdateQuantity: Int
    let t1Quantity: Int
    let exchange: String
    
    // Custom Coding Keys to map JSON keys to struct property names
    enum CodingKeys: String, CodingKey {
        case isin, product, quantity, exchange
        case cncUsedQuantity = "cnc_used_quantity"
        case collateralType = "collateral_type"
        case companyName = "company_name"
        case tradingSymbol = "tradingsymbol"
        case lastPrice = "last_price"
        case closePrice = "close_price"
        case pnl, haircut
        case dayChangePercentage = "day_change_percentage"
        case instrumentToken = "instrument_token"
        case averagePrice = "average_price"
        case collateralQuantity = "collateral_quantity"
        case collateralUpdateQuantity = "collateral_update_quantity"
        case t1Quantity = "t1_quantity"
    }
    var  dayChange: Double  {
        return (lastPrice-closePrice)*Double(quantity)
    }
    var  pnlPercent: Double  {
        return (lastPrice-averagePrice)/averagePrice*100
    }
}
