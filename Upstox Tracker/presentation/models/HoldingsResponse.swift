//
//  HoldingsResponse.swift
//  Upstox Tracker
//
//  Created by Nidhin Rejoice on 08/07/24.
//

import Foundation

struct HoldingsResponse: Codable {
   let status: String
   let data: [Stock]
}
