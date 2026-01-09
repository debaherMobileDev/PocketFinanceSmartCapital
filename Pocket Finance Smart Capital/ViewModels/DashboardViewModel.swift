//
//  DashboardViewModel.swift
//  Pocket Finance Smart Capital
//
//  Created by Simon Bakhanets on 09.01.2026.
//

import Foundation
import Combine

class DashboardViewModel: ObservableObject {
    @Published var totalExpenses: Double = 0
    @Published var totalBudget: Double = 0
    @Published var budgetRemaining: Double = 0
    @Published var totalInvestmentValue: Double = 0
    @Published var totalInvestmentGainLoss: Double = 0
    @Published var recentExpenses: [Expense] = []
    @Published var topCategories: [(category: ExpenseCategory, amount: Double)] = []
    
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
        
        dataService.$budgets
            .sink { [weak self] _ in
                self?.updateData()
            }
            .store(in: &cancellables)
        
        dataService.$investments
            .sink { [weak self] _ in
                self?.updateData()
            }
            .store(in: &cancellables)
    }
    
    func updateData() {
        totalExpenses = dataService.getTotalExpenses()
        totalBudget = dataService.getTotalBudgetLimit()
        budgetRemaining = totalBudget - dataService.getTotalBudgetSpent()
        totalInvestmentValue = dataService.getTotalInvestmentValue()
        totalInvestmentGainLoss = dataService.getTotalGainLoss()
        
        recentExpenses = Array(dataService.getExpensesForCurrentMonth()
            .sorted(by: { $0.date > $1.date })
            .prefix(5))
        
        let categoryExpenses = dataService.getExpensesByCategory()
        topCategories = categoryExpenses
            .map { (category: $0.key, amount: $0.value) }
            .sorted(by: { $0.amount > $1.amount })
            .prefix(3)
            .map { $0 }
    }
}

