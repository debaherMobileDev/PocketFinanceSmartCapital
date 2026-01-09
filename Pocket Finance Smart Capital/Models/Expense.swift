//
//  Expense.swift
//  Pocket Finance Smart Capital
//
//  Created by Simon Bakhanets on 09.01.2026.
//

import Foundation

struct Expense: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var amount: Double
    var category: ExpenseCategory
    var date: Date
    var notes: String
    
    init(id: UUID = UUID(), title: String, amount: Double, category: ExpenseCategory, date: Date = Date(), notes: String = "") {
        self.id = id
        self.title = title
        self.amount = amount
        self.category = category
        self.date = date
        self.notes = notes
    }
}

enum ExpenseCategory: String, Codable, CaseIterable {
    case food = "Food"
    case transport = "Transport"
    case shopping = "Shopping"
    case entertainment = "Entertainment"
    case health = "Health"
    case education = "Education"
    case utilities = "Utilities"
    case other = "Other"
    
    var iconName: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "car.fill"
        case .shopping: return "cart.fill"
        case .entertainment: return "tv.fill"
        case .health: return "heart.fill"
        case .education: return "book.fill"
        case .utilities: return "house.fill"
        case .other: return "circle.fill"
        }
    }
}

