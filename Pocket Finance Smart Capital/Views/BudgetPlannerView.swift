//
//  BudgetPlannerView.swift
//  Pocket Finance Smart Capital
//
//  Created by Simon Bakhanets on 09.01.2026.
//

import SwiftUI

struct BudgetPlannerView: View {
    @StateObject private var viewModel = BudgetPlannerViewModel()
    @State private var selectedBudget: IdentifiableBudget?
    @State private var showingAddBudget = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: Constants.sectionSpacing) {
                // Header
                headerSection
                
                // Summary
                summarySection
                
                // Overall Progress
                overallProgressSection
                
                // Budgets List
                budgetsListSection
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
        .sheet(isPresented: $showingAddBudget) {
            AddBudgetView(viewModel: viewModel)
        }
        .sheet(item: $selectedBudget) { identifiableBudget in
            EditBudgetView(budget: identifiableBudget.budget, viewModel: viewModel)
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Budget Planner")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                
                Text(currentMonth)
                    .font(.system(size: 17))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Button(action: {
                showingAddBudget = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.appGreen)
            }
        }
    }
    
    private var currentMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.monthFormat
        return formatter.string(from: Date())
    }
    
    // MARK: - Summary Section
    
    private var summarySection: some View {
        HStack(spacing: 12) {
            SummaryCard(
                title: "Total Budget",
                value: viewModel.totalBudget,
                icon: "banknote.fill",
                color: .appGreen
            )
            
            SummaryCard(
                title: "Remaining",
                value: viewModel.totalRemaining,
                icon: "dollarsign.circle.fill",
                color: viewModel.totalRemaining >= 0 ? .appGreen : .appRed
            )
        }
    }
    
    // MARK: - Overall Progress Section
    
    private var overallProgressSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "chart.pie.fill")
                        .foregroundColor(.appGreen)
                    Text("Overall Progress")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                }
                
                if viewModel.totalBudget > 0 {
                    let percentage = min((viewModel.totalSpent / viewModel.totalBudget) * 100, 100)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("\(Constants.currencySymbol)\(viewModel.totalSpent, specifier: "%.2f")")
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
                    Text("No budgets set for this month")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }
    
    // MARK: - Budgets List Section
    
    private var budgetsListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "list.bullet")
                    .foregroundColor(.appGreen)
                Text("Category Budgets")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }
            
            if viewModel.budgets.isEmpty {
                emptyStateView
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.budgets) { budget in
                        BudgetCard(budget: budget) {
                            selectedBudget = IdentifiableBudget(budget: budget)
                        } onDelete: {
                            viewModel.deleteBudget(budget)
                        }
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        GlassCard {
            VStack(spacing: 16) {
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white.opacity(0.3))
                
                Text("No budgets set")
                    .font(.system(size: 17))
                    .foregroundColor(.white.opacity(0.7))
                
                Text("Tap the + button to create your first budget")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 40)
        }
    }
}

// MARK: - Supporting Views

struct BudgetCard: View {
    let budget: Budget
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        GlassCard {
            VStack(spacing: 16) {
                // Header
                HStack {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.appGreen.opacity(0.2))
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: budget.category.iconName)
                                .font(.system(size: 20))
                                .foregroundColor(.appGreen)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(budget.category.rawValue)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text("\(Constants.currencySymbol)\(budget.spent, specifier: "%.2f") / \(Constants.currencySymbol)\(budget.limit, specifier: "%.2f")")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(budget.isOverBudget ? "Over Budget" : "Remaining")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text("\(budget.remaining >= 0 ? "" : "-")\(Constants.currencySymbol)\(abs(budget.remaining), specifier: "%.2f")")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(budget.isOverBudget ? .appRed : .appGreen)
                    }
                }
                
                // Progress Bar
                VStack(spacing: 6) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 8)
                            
                            // Progress
                            RoundedRectangle(cornerRadius: 4)
                                .fill(budget.isOverBudget ? Color.appRed : Color.appGreen)
                                .frame(
                                    width: min(CGFloat(budget.percentageUsed / 100) * geometry.size.width, geometry.size.width),
                                    height: 8
                                )
                        }
                    }
                    .frame(height: 8)
                    
                    HStack {
                        Text("\(budget.percentageUsed, specifier: "%.1f")% used")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Spacer()
                        
                        if budget.isOverBudget {
                            Text("⚠️ Over budget")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.appRed)
                        }
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
        }
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct IdentifiableBudget: Identifiable {
    let id = UUID()
    let budget: Budget
}

// MARK: - Add Budget View

struct AddBudgetView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: BudgetPlannerViewModel
    
    @State private var selectedCategory = ExpenseCategory.food
    @State private var limit = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Category
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            Picker("Category", selection: $selectedCategory) {
                                ForEach(ExpenseCategory.allCases, id: \.self) { category in
                                    HStack {
                                        Image(systemName: category.iconName)
                                        Text(category.rawValue)
                                    }
                                    .tag(category)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.glassBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.glassBorder, lineWidth: 1)
                            )
                            
                            if viewModel.hasBudgetForCategory(selectedCategory) {
                                Text("⚠️ Budget already exists for this category")
                                    .font(.system(size: 13))
                                    .foregroundColor(.appRed)
                            }
                        }
                        
                        // Budget Limit
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Monthly Budget Limit")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("0.00", text: $limit)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Info Box
                        HStack(spacing: 12) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.appGreen)
                            
                            Text("Set a monthly spending limit for this category. You'll be notified when you approach or exceed this limit.")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding()
                        .background(Color.glassBackground)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.glassBorder, lineWidth: 1)
                        )
                        
                        // Add Button
                        Button(action: addBudget) {
                            Text("Create Budget")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.appGreen)
                                .cornerRadius(16)
                        }
                        .disabled(!isValid)
                        .opacity(isValid ? 1 : 0.5)
                        .padding(.top)
                    }
                    .padding()
                }
            }
            .navigationTitle("Add Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    private var isValid: Bool {
        !viewModel.hasBudgetForCategory(selectedCategory) &&
        Double(limit) != nil && Double(limit)! > 0
    }
    
    private func addBudget() {
        guard let limitValue = Double(limit) else { return }
        viewModel.addBudget(category: selectedCategory, limit: limitValue)
        dismiss()
    }
}

// MARK: - Edit Budget View

struct EditBudgetView: View {
    @Environment(\.dismiss) var dismiss
    let budget: Budget
    @ObservedObject var viewModel: BudgetPlannerViewModel
    
    @State private var limit = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Category Display
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            HStack {
                                Image(systemName: budget.category.iconName)
                                    .foregroundColor(.appGreen)
                                Text(budget.category.rawValue)
                                    .font(.system(size: 17))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding()
                            .background(Color.glassBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.glassBorder, lineWidth: 1)
                            )
                        }
                        
                        // Current Spending
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Current Spending")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            HStack {
                                Text("\(Constants.currencySymbol)\(budget.spent, specifier: "%.2f")")
                                    .font(.system(size: 17))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding()
                            .background(Color.glassBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.glassBorder, lineWidth: 1)
                            )
                        }
                        
                        // Budget Limit
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Monthly Budget Limit")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("0.00", text: $limit)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Update Button
                        Button(action: updateBudget) {
                            Text("Update Budget")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.appGreen)
                                .cornerRadius(16)
                        }
                        .disabled(!isValid)
                        .opacity(isValid ? 1 : 0.5)
                        .padding(.top)
                    }
                    .padding()
                }
            }
            .navigationTitle("Edit Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .onAppear {
                limit = String(budget.limit)
            }
        }
    }
    
    private var isValid: Bool {
        Double(limit) != nil && Double(limit)! > 0
    }
    
    private func updateBudget() {
        guard let limitValue = Double(limit) else { return }
        var updatedBudget = budget
        updatedBudget.limit = limitValue
        viewModel.updateBudget(updatedBudget)
        dismiss()
    }
}

