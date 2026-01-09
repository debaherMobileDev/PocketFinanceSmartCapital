//
//  BudgetPlannerViewModel.swift
//  Pocket Finance Smart Capital
//
//  Created by Simon Bakhanets on 09.01.2026.
//

import Foundation
import Combine

class BudgetPlannerViewModel: ObservableObject {
    @Published var budgets: [Budget] = []
    @Published var totalBudget: Double = 0
    @Published var totalSpent: Double = 0
    @Published var totalRemaining: Double = 0
    
    private let dataService = FinanceDataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupObservers()
        updateData()
    }
    
    private func setupObservers() {
        dataService.$budgets
            .sink { [weak self] _ in
                self?.updateData()
            }
            .store(in: &cancellables)
        
        dataService.$expenses
            .sink { [weak self] _ in
                self?.updateData()
            }
            .store(in: &cancellables)
    }
    
    func updateData() {
        budgets = dataService.getBudgetsForCurrentMonth()
            .sorted(by: { $0.category.rawValue < $1.category.rawValue })
        totalBudget = dataService.getTotalBudgetLimit()
        totalSpent = dataService.getTotalBudgetSpent()
        totalRemaining = totalBudget - totalSpent
    }
    
    func addBudget(category: ExpenseCategory, limit: Double) {
        let budget = Budget(category: category, limit: limit, month: Date())
        dataService.addBudget(budget)
    }
    
    func updateBudget(_ budget: Budget) {
        dataService.updateBudget(budget)
    }
    
    func deleteBudget(_ budget: Budget) {
        dataService.deleteBudget(budget)
    }
    
    func hasBudgetForCategory(_ category: ExpenseCategory) -> Bool {
        budgets.contains(where: { $0.category == category })
    }
}

