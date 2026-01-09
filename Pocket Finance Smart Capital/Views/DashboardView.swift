//
//  DashboardView.swift
//  Pocket Finance Smart Capital
//
//  Created by Simon Bakhanets on 09.01.2026.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: Constants.sectionSpacing) {
                // Header
                headerSection
                
                // Summary Cards
                summaryCardsSection
                
                // Budget Progress
                budgetProgressSection
                
                // Investment Summary
                investmentSummarySection
                
                // Recent Expenses
                recentExpensesSection
                
                // Top Categories
                topCategoriesSection
            }
            .padding()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.appBackground, Color.appSecondaryBackground]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .onAppear {
            viewModel.updateData()
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Dashboard")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)
            
            Text(currentMonthYear)
                .font(.system(size: 17))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var currentMonthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.monthFormat
        return formatter.string(from: Date())
    }
    
    // MARK: - Summary Cards Section
    
    private var summaryCardsSection: some View {
        HStack(spacing: 12) {
            SummaryCard(
                title: "Total Expenses",
                value: viewModel.totalExpenses,
                icon: "creditcard.fill",
                color: .appRed
            )
            
            SummaryCard(
                title: "Budget Left",
                value: viewModel.budgetRemaining,
                icon: "banknote.fill",
                color: .appGreen
            )
        }
    }
    
    // MARK: - Budget Progress Section
    
    private var budgetProgressSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.appGreen)
                    Text("Budget Progress")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                }
                
                if viewModel.totalBudget > 0 {
                    let percentage = min((viewModel.totalExpenses / viewModel.totalBudget) * 100, 100)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("\(Constants.currencySymbol)\(viewModel.totalExpenses, specifier: "%.2f")")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            Text("of \(Constants.currencySymbol)\(viewModel.totalBudget, specifier: "%.2f")")
                                .font(.system(size: 17))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        ProgressView(value: percentage, total: 100)
                            .tint(percentage > 90 ? Color.appRed : Color.appGreen)
                        
                        Text("\(percentage, specifier: "%.1f")% used")
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.7))
                    }
                } else {
                    Text("No budget set for this month")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }
    
    // MARK: - Investment Summary Section
    
    private var investmentSummarySection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(.appGreen)
                    Text("Investments")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Portfolio Value")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(Constants.currencySymbol)\(viewModel.totalInvestmentValue, specifier: "%.2f")")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Gain/Loss")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(viewModel.totalInvestmentGainLoss >= 0 ? "+" : "")\(Constants.currencySymbol)\(viewModel.totalInvestmentGainLoss, specifier: "%.2f")")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(viewModel.totalInvestmentGainLoss >= 0 ? .appGreen : .appRed)
                    }
                }
            }
        }
    }
    
    // MARK: - Recent Expenses Section
    
    private var recentExpensesSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.appGreen)
                    Text("Recent Expenses")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                }
                
                if viewModel.recentExpenses.isEmpty {
                    Text("No expenses recorded yet")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.7))
                } else {
                    VStack(spacing: 12) {
                        ForEach(viewModel.recentExpenses) { expense in
                            ExpenseRowView(expense: expense)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Top Categories Section
    
    private var topCategoriesSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "square.grid.2x2.fill")
                        .foregroundColor(.appGreen)
                    Text("Top Categories")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                }
                
                if viewModel.topCategories.isEmpty {
                    Text("No spending data available")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.7))
                } else {
                    VStack(spacing: 12) {
                        ForEach(viewModel.topCategories, id: \.category) { item in
                            HStack {
                                Image(systemName: item.category.iconName)
                                    .foregroundColor(.appGreen)
                                    .frame(width: 24)
                                
                                Text(item.category.rawValue)
                                    .font(.system(size: 15))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("\(Constants.currencySymbol)\(item.amount, specifier: "%.2f")")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct SummaryCard: View {
    let title: String
    let value: Double
    let icon: String
    let color: Color
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 24))
                
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))
                
                Text("\(Constants.currencySymbol)\(value, specifier: "%.2f")")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct GlassCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(Constants.cardPadding)
            .background(Color.glassBackground)
            .cornerRadius(Constants.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .stroke(Color.glassBorder, lineWidth: 1)
            )
    }
}

struct ExpenseRowView: View {
    let expense: Expense
    
    var body: some View {
        HStack {
            Image(systemName: expense.category.iconName)
                .foregroundColor(.appGreen)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                
                Text(formatDate(expense.date))
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Text("\(Constants.currencySymbol)\(expense.amount, specifier: "%.2f")")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        return formatter.string(from: date)
    }
}

