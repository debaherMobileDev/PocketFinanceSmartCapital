//
//  SeedData.swift
//  Pocket Finance Smart Capital
//
//  Created by Simon Bakhanets on 09.01.2026.
//

import Foundation

struct SeedData {
    static func loadSampleData() {
        #if DEBUG
        let dataService = FinanceDataService.shared
        
        // Проверяем, нужно ли загружать данные
        if !dataService.expenses.isEmpty || !dataService.investments.isEmpty || !dataService.budgets.isEmpty {
            print("Sample data already exists, skipping seed...")
            return
        }
        
        print("Loading sample data...")
        
        // MARK: - Sample Expenses
        
        let expenses = [
            // Еда
            Expense(title: "Grocery Shopping", amount: 125.50, category: .food, date: daysAgo(2)),
            Expense(title: "Restaurant Dinner", amount: 85.00, category: .food, date: daysAgo(5)),
            Expense(title: "Coffee & Breakfast", amount: 15.75, category: .food, date: daysAgo(1)),
            Expense(title: "Lunch at Cafe", amount: 22.50, category: .food, date: daysAgo(3)),
            
            // Транспорт
            Expense(title: "Gas Station", amount: 65.00, category: .transport, date: daysAgo(4)),
            Expense(title: "Uber Ride", amount: 18.50, category: .transport, date: daysAgo(1)),
            Expense(title: "Parking Fee", amount: 12.00, category: .transport, date: daysAgo(6)),
            
            // Покупки
            Expense(title: "New Headphones", amount: 199.99, category: .shopping, date: daysAgo(7)),
            Expense(title: "Clothing Store", amount: 145.00, category: .shopping, date: daysAgo(10)),
            Expense(title: "Online Shopping", amount: 75.50, category: .shopping, date: daysAgo(3)),
            
            // Развлечения
            Expense(title: "Movie Tickets", amount: 35.00, category: .entertainment, date: daysAgo(8)),
            Expense(title: "Spotify Premium", amount: 9.99, category: .entertainment, date: daysAgo(15)),
            Expense(title: "Concert Tickets", amount: 120.00, category: .entertainment, date: daysAgo(12)),
            
            // Здоровье
            Expense(title: "Gym Membership", amount: 49.99, category: .health, date: daysAgo(1)),
            Expense(title: "Pharmacy", amount: 28.75, category: .health, date: daysAgo(9)),
            
            // Образование
            Expense(title: "Online Course", amount: 79.99, category: .education, date: daysAgo(14)),
            Expense(title: "Books", amount: 45.00, category: .education, date: daysAgo(11)),
            
            // Коммунальные услуги
            Expense(title: "Electricity Bill", amount: 125.00, category: .utilities, date: daysAgo(5)),
            Expense(title: "Internet Service", amount: 59.99, category: .utilities, date: daysAgo(2)),
            
            // Прочее
            Expense(title: "Gift for Friend", amount: 55.00, category: .other, date: daysAgo(6)),
            Expense(title: "Home Supplies", amount: 42.50, category: .other, date: daysAgo(4))
        ]
        
        for expense in expenses {
            dataService.addExpense(expense)
        }
        
        // MARK: - Sample Investments
        
        let investments = [
            Investment(
                symbol: "AAPL",
                name: "Apple Inc.",
                shares: 10,
                purchasePrice: 150.00,
                currentPrice: 185.25,
                purchaseDate: daysAgo(90)
            ),
            Investment(
                symbol: "MSFT",
                name: "Microsoft Corporation",
                shares: 8,
                purchasePrice: 320.00,
                currentPrice: 378.50,
                purchaseDate: daysAgo(120)
            ),
            Investment(
                symbol: "GOOGL",
                name: "Alphabet Inc.",
                shares: 5,
                purchasePrice: 125.00,
                currentPrice: 142.75,
                purchaseDate: daysAgo(60)
            ),
            Investment(
                symbol: "TSLA",
                name: "Tesla Inc.",
                shares: 12,
                purchasePrice: 220.00,
                currentPrice: 245.80,
                purchaseDate: daysAgo(45)
            ),
            Investment(
                symbol: "AMZN",
                name: "Amazon.com Inc.",
                shares: 6,
                purchasePrice: 135.00,
                currentPrice: 148.90,
                purchaseDate: daysAgo(75)
            )
        ]
        
        for investment in investments {
            dataService.addInvestment(investment)
        }
        
        // MARK: - Sample Budgets
        
        let budgets = [
            Budget(category: .food, limit: 500.00, month: Date()),
            Budget(category: .transport, limit: 200.00, month: Date()),
            Budget(category: .shopping, limit: 300.00, month: Date()),
            Budget(category: .entertainment, limit: 150.00, month: Date()),
            Budget(category: .health, limit: 100.00, month: Date()),
            Budget(category: .utilities, limit: 250.00, month: Date())
        ]
        
        for budget in budgets {
            dataService.addBudget(budget)
        }
        
        print("Sample data loaded successfully!")
        print("- \(expenses.count) expenses")
        print("- \(investments.count) investments")
        print("- \(budgets.count) budgets")
        #endif
    }
    
    private static func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
    }
}

