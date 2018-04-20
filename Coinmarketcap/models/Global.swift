//
//  Global.swift
//  Coinmarketcap
//
//  Created by Nikodem Strawa on 17/04/2018.
//  Copyright © 2018 Nikodem Strawa. All rights reserved.
//

import UIKit





struct Global: Decodable {
    var totalMarketCapUsd: Int
    var bitcoinPercentageOfMarketCap: Double
    
    private enum CodingKeys: String, CodingKey {
        case totalMarketCapUsd = "total_market_cap_usd"
        case bitcoinPercentageOfMarketCap = "bitcoin_percentage_of_market_cap"
    }
}

extension Global {
    var marketCapUsd: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.currencySymbol = "$"
        numberFormatter.groupingSize = 3
        numberFormatter.groupingSeparator = ","
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.numberStyle = .currencyAccounting
        guard let formated = numberFormatter.string(from: NSNumber(value: self.totalMarketCapUsd)) else { return "0"}
        return formated
    }
    var btcDominance: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .percent
        numberFormatter.groupingSize = 2
        guard let formated = numberFormatter.string(from: NSNumber(value: self.bitcoinPercentageOfMarketCap)) else {return "0"}
        return formated
    }
}
