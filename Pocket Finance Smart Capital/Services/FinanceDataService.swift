//
//  FinanceDataService.swift
//  Pocket Finance Smart Capital
//
//  Created by Simon Bakhanets on 09.01.2026.
//

import Foundation

class FinanceDataService: ObservableObject {
    static let shared = FinanceDataService()
    
    @Published var expenses: [Expense] = []
    @Published var investments: [Investment] = []
    @Published var budgets: [Budget] = []
    
    private init() {
        loadData()
    }
    
    // MARK: - Expense Methods
    
    func addExpense(_ expense: Expense) {
        expenses.append(expense)
        updateBudgetForExpense(expense)
        saveExpenses()
    }
    
    func updateExpense(_ expense: Expense) {
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
            expenses[index] = expense
            saveExpenses()
            recalculateBudgets()
        }
    }
    
    func deleteExpense(_ expense: Expense) {
        expenses.removeAll { $0.id == expense.id }
        saveExpenses()
        recalculateBudgets()
    }
    
    func getExpensesForCurrentMonth() -> [Expense] {
        let calendar = Calendar.current
        let now = Date()
        return expenses.filter { expense in
            calendar.isDate(expense.date, equalTo: now, toGranularity: .month)
        }
    }
    
    func getTotalExpenses() -> Double {
        getExpensesForCurrentMonth().reduce(0) { $0 + $1.amount }
    }
    
    func getExpensesByCategory() -> [ExpenseCategory: Double] {
        var result: [ExpenseCategory: Double] = [:]
        let monthExpenses = getExpensesForCurrentMonth()
        
        for expense in monthExpenses {
            result[expense.category, default: 0] += expense.amount
        }
        
        return result
    }
    
    // MARK: - Investment Methods
    
    func addInvestment(_ investment: Investment) {
        investments.append(investment)
        saveInvestments()
    }
    
    func updateInvestment(_ investment: Investment) {
        if let index = investments.firstIndex(where: { $0.id == investment.id }) {
            investments[index] = investment
            saveInvestments()
        }
    }
    
    func deleteInvestment(_ investment: Investment) {
        investments.removeAll { $0.id == investment.id }
        saveInvestments()
    }
    
    func getTotalInvestmentValue() -> Double {
        investments.reduce(0) { $0 + $1.totalValue }
    }
    
    func getTotalInvestmentCost() -> Double {
        investments.reduce(0) { $0 + $1.totalCost }
    }
    
    func getTotalGainLoss() -> Double {
        investments.reduce(0) { $0 + $1.gainLoss }
    }
    
    // MARK: - Budget Methods
    
    func addBudget(_ budget: Budget) {
        budgets.append(budget)
        saveBudgets()
    }
    
    func updateBudget(_ budget: Budget) {
        if let index = budgets.firstIndex(where: { $0.id == budget.id }) {
            budgets[index] = budget
            saveBudgets()
        }
    }
    
    func deleteBudget(_ budget: Budget) {
        budgets.removeAll { $0.id == budget.id }
        saveBudgets()
    }
    
    func getBudgetsForCurrentMonth() -> [Budget] {
        let calendar = Calendar.current
        let now = Date()
        return budgets.filter { budget in
            calendar.isDate(budget.month, equalTo: now, toGranularity: .month)
        }
    }
    
    func getTotalBudgetLimit() -> Double {
        getBudgetsForCurrentMonth().reduce(0) { $0 + $1.limit }
    }
    
    func getTotalBudgetSpent() -> Double {
        getBudgetsForCurrentMonth().reduce(0) { $0 + $1.spent }
    }
    
    private func updateBudgetForExpense(_ expense: Expense) {
        let calendar = Calendar.current
        if let budget = budgets.first(where: {
            $0.category == expense.category &&
            calendar.isDate($0.month, equalTo: expense.date, toGranularity: .month)
        }) {
            var updatedBudget = budget
            updatedBudget.spent += expense.amount
            updateBudget(updatedBudget)
        }
    }
    
    private func recalculateBudgets() {
        let calendar = Calendar.current
        
        for budget in budgets {
            let categoryExpenses = expenses.filter {
                $0.category == budget.category &&
                calendar.isDate($0.date, equalTo: budget.month, toGranularity: .month)
            }
            
            var updatedBudget = budget
            updatedBudget.spent = categoryExpenses.reduce(0) { $0 + $1.amount }
            updateBudget(updatedBudget)
        }
    }
    
    // MARK: - Data Persistence
    
    private func loadData() {
        loadExpenses()
        loadInvestments()
        loadBudgets()
    }
    
    private func saveExpenses() {
        if let encoded = try? JSONEncoder().encode(expenses) {
            UserDefaults.standard.set(encoded, forKey: Constants.expensesKey)
        }
    }
    
    private func loadExpenses() {
        if let data = UserDefaults.standard.data(forKey: Constants.expensesKey),
           let decoded = try? JSONDecoder().decode([Expense].self, from: data) {
            expenses = decoded
        }
    }
    
    private func saveInvestments() {
        if let encoded = try? JSONEncoder().encode(investments) {
            UserDefaults.standard.set(encoded, forKey: Constants.investmentsKey)
        }
    }
    
    private func loadInvestments() {
        if let data = UserDefaults.standard.data(forKey: Constants.investmentsKey),
           let decoded = try? JSONDecoder().decode([Investment].self, from: data) {
            investments = decoded
        }
    }
    
    private func saveBudgets() {
        if let encoded = try? JSONEncoder().encode(budgets) {
            UserDefaults.standard.set(encoded, forKey: Constants.budgetsKey)
        }
    }
    
    private func loadBudgets() {
        if let data = UserDefaults.standard.data(forKey: Constants.budgetsKey),
           let decoded = try? JSONDecoder().decode([Budget].self, from: data) {
            budgets = decoded
        }
    }
    
    // MARK: - Reset Data
    
    func resetAllData() {
        expenses.removeAll()
        investments.removeAll()
        budgets.removeAll()
        
        UserDefaults.standard.removeObject(forKey: Constants.expensesKey)
        UserDefaults.standard.removeObject(forKey: Constants.investmentsKey)
        UserDefaults.standard.removeObject(forKey: Constants.budgetsKey)
        UserDefaults.standard.removeObject(forKey: Constants.hasCompletedOnboarding)
    }
}

