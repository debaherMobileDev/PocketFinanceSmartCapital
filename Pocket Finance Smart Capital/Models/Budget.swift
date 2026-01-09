//
//  Budget.swift
//  Pocket Finance Smart Capital
//
//  Created by Simon Bakhanets on 09.01.2026.
//

import Foundation

struct Budget: Identifiable, Codable {
    var id: UUID = UUID()
    var category: ExpenseCategory
    var limit: Double
    var spent: Double
    var month: Date
    
    var remaining: Double {
        limit - spent
    }
    
    var percentageUsed: Double {
        guard limit > 0 else { return 0 }
        return (spent / limit) * 100
    }
    
    var isOverBudget: Bool {
        spent > limit
    }
    
    init(id: UUID = UUID(), category: ExpenseCategory, limit: Double, spent: Double = 0, month: Date = Date()) {
        self.id = id
        self.category = category
        self.limit = limit
        self.spent = spent
        self.month = month
    }
}

