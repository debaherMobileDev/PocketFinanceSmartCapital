//
//  Investment.swift
//  Pocket Finance Smart Capital
//
//  Created by Simon Bakhanets on 09.01.2026.
//

import Foundation

struct Investment: Identifiable, Codable {
    var id: UUID = UUID()
    var symbol: String
    var name: String
    var shares: Double
    var purchasePrice: Double
    var currentPrice: Double
    var purchaseDate: Date
    
    var totalValue: Double {
        shares * currentPrice
    }
    
    var totalCost: Double {
        shares * purchasePrice
    }
    
    var gainLoss: Double {
        totalValue - totalCost
    }
    
    var gainLossPercentage: Double {
        guard totalCost > 0 else { return 0 }
        return (gainLoss / totalCost) * 100
    }
    
    init(id: UUID = UUID(), symbol: String, name: String, shares: Double, purchasePrice: Double, currentPrice: Double, purchaseDate: Date = Date()) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.shares = shares
        self.purchasePrice = purchasePrice
        self.currentPrice = currentPrice
        self.purchaseDate = purchaseDate
    }
}

