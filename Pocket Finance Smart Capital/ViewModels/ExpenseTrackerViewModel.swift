//
//  ExpenseTrackerViewModel.swift
//  Pocket Finance Smart Capital
//
//  Created by Simon Bakhanets on 09.01.2026.
//

import Foundation
import Combine

class ExpenseTrackerViewModel: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var selectedCategory: ExpenseCategory?
    @Published var totalExpenses: Double = 0
    @Published var categoryBreakdown: [ExpenseCategory: Double] = [:]
    
    private let dataService = FinanceDataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupObservers()
        updateData()
    }
    
    private func setupObservers() {
        dataService.$expenses
            .sink { [weak self] _ in
                self?.updateData()
            }
            .store(in: &cancellables)
    }
    
    func updateData() {
        expenses = dataService.getExpensesForCurrentMonth()
            .sorted(by: { $0.date > $1.date })
        totalExpenses = dataService.getTotalExpenses()
        categoryBreakdown = dataService.getExpensesByCategory()
    }
    
    func addExpense(title: String, amount: Double, category: ExpenseCategory, date: Date, notes: String) {
        let expense = Expense(title: title, amount: amount, category: category, date: date, notes: notes)
        dataService.addExpense(expense)
    }
    
    func updateExpense(_ expense: Expense) {
        dataService.updateExpense(expense)
    }
    
    func deleteExpense(_ expense: Expense) {
        dataService.deleteExpense(expense)
    }
    
    func getFilteredExpenses() -> [Expense] {
        if let category = selectedCategory {
            return expenses.filter { $0.category == category }
        }
        return expenses
    }
}

