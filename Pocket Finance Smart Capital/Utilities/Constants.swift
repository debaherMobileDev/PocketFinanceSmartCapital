//
//  Constants.swift
//  Pocket Finance Smart Capital
//
//  Created by Simon Bakhanets on 09.01.2026.
//

import Foundation

struct Constants {
    // UserDefaults Keys
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let expensesKey = "savedExpenses"
    static let investmentsKey = "savedInvestments"
    static let budgetsKey = "savedBudgets"
    
    // UI Constants
    static let cornerRadius: CGFloat = 20
    static let cardPadding: CGFloat = 16
    static let sectionSpacing: CGFloat = 20
    
    // Animation
    static let standardAnimation = 0.3
    
    // Currency
    static let currencySymbol = "$"
    
    // Date Formats
    static let dateFormat = "MMM dd, yyyy"
    static let monthFormat = "MMMM yyyy"
}

