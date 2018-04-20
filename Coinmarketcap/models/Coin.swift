//
//  Coin.swift
//  Coinmarketcap
//
//  Created by Nikodem Strawa on 14/04/2018.
//  Copyright © 2018 Nikodem Strawa. All rights reserved.
//

import UIKit

struct Coin: Decodable {
    var id: String
    var name: String
    var rank: String
    var symbol: String
    var priceUsd: String?
    var marketCapUsd: String?
    var percentChange24h: String?
    
    private enum CodingKeys: String, CodingKey {
        case percentChange24h = "percent_change_24h"
        case priceUsd = "price_usd"
        case marketCapUsd = "market_cap_usd"
        case id, name, rank, symbol
    }
}

extension Coin {
    var percentChange24Double: Double? {
        guard let percent = self.percentChange24h else { return nil }
        return Double(percent)
    }
    var price: String {
        let numberFormatter = NumberFormatter()
        let doubleVal = Double(self.priceUsd!)
        numberFormatter.currencySymbol = "$"
        numberFormatter.maximumFractionDigits = 4
        numberFormatter.numberStyle = .currencyAccounting
        guard let formated = numberFormatter.string(from: NSNumber(value: doubleVal!)) else {return "0"}
        return formated
    }
    
}

