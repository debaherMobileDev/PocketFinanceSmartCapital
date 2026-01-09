//
//  ExpenseTrackerView.swift
//  Pocket Finance Smart Capital
//
//  Created by Simon Bakhanets on 09.01.2026.
//

import SwiftUI

struct ExpenseTrackerView: View {
    @StateObject private var viewModel = ExpenseTrackerViewModel()
    @State private var selectedExpense: IdentifiableExpense?
    @State private var showingAddExpense = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: Constants.sectionSpacing) {
                // Header
                headerSection
                
                // Summary
                summarySection
                
                // Category Filter
                categoryFilterSection
                
                // Expenses List
                expensesListSection
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
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(viewModel: viewModel)
        }
        .sheet(item: $selectedExpense) { identifiableExpense in
            EditExpenseView(expense: identifiableExpense.expense, viewModel: viewModel)
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Expense Tracker")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                
                Text("\(viewModel.getFilteredExpenses().count) expenses")
                    .font(.system(size: 17))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Button(action: {
                showingAddExpense = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.appGreen)
            }
        }
    }
    
    // MARK: - Summary Section
    
    private var summarySection: some View {
        GlassCard {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total Expenses")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("\(Constants.currencySymbol)\(viewModel.totalExpenses, specifier: "%.2f")")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.appRed.opacity(0.5))
            }
        }
    }
    
    // MARK: - Category Filter Section
    
    private var categoryFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryFilterButton(
                    title: "All",
                    isSelected: viewModel.selectedCategory == nil
                ) {
                    viewModel.selectedCategory = nil
                }
                
                ForEach(ExpenseCategory.allCases, id: \.self) { category in
                    CategoryFilterButton(
                        title: category.rawValue,
                        icon: category.iconName,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        viewModel.selectedCategory = category
                    }
                }
            }
        }
    }
    
    // MARK: - Expenses List Section
    
    private var expensesListSection: some View {
        VStack(spacing: 12) {
            if viewModel.getFilteredExpenses().isEmpty {
                emptyStateView
            } else {
                ForEach(viewModel.getFilteredExpenses()) { expense in
                    ExpenseCard(expense: expense) {
                        selectedExpense = IdentifiableExpense(expense: expense)
                    } onDelete: {
                        viewModel.deleteExpense(expense)
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        GlassCard {
            VStack(spacing: 16) {
                Image(systemName: "tray.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white.opacity(0.3))
                
                Text("No expenses found")
                    .font(.system(size: 17))
                    .foregroundColor(.white.opacity(0.7))
                
                Text("Tap the + button to add your first expense")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 40)
        }
    }
}

// MARK: - Supporting Views

struct CategoryFilterButton: View {
    let title: String
    var icon: String?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                }
                
                Text(title)
                    .font(.system(size: 15, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? Color.appGreen : Color.glassBackground)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.clear : Color.glassBorder, lineWidth: 1)
            )
        }
    }
}

struct ExpenseCard: View {
    let expense: Expense
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        GlassCard {
            HStack {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.appGreen.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: expense.category.iconName)
                        .font(.system(size: 22))
                        .foregroundColor(.appGreen)
                }
                
                // Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(expense.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 8) {
                        Text(expense.category.rawValue)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text("•")
                            .foregroundColor(.white.opacity(0.4))
                        
                        Text(formatDate(expense.date))
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                Spacer()
                
                // Amount
                Text("\(Constants.currencySymbol)\(expense.amount, specifier: "%.2f")")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        return formatter.string(from: date)
    }
}

struct IdentifiableExpense: Identifiable {
    let id = UUID()
    let expense: Expense
}

// MARK: - Add Expense View

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ExpenseTrackerViewModel
    
    @State private var title = ""
    @State private var amount = ""
    @State private var selectedCategory = ExpenseCategory.food
    @State private var date = Date()
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("Enter expense title", text: $title)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Amount
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Amount")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("0.00", text: $amount)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
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
                        }
                        
                        // Date
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            DatePicker("", selection: $date, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .colorScheme(.dark)
                                .padding()
                                .background(Color.glassBackground)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.glassBorder, lineWidth: 1)
                                )
                        }
                        
                        // Notes
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes (Optional)")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("Add notes", text: $notes)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Add Button
                        Button(action: addExpense) {
                            Text("Add Expense")
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
            .navigationTitle("Add Expense")
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
        !title.isEmpty && Double(amount) != nil && Double(amount)! > 0
    }
    
    private func addExpense() {
        guard let amountValue = Double(amount) else { return }
        viewModel.addExpense(title: title, amount: amountValue, category: selectedCategory, date: date, notes: notes)
        dismiss()
    }
}

// MARK: - Edit Expense View

struct EditExpenseView: View {
    @Environment(\.dismiss) var dismiss
    let expense: Expense
    @ObservedObject var viewModel: ExpenseTrackerViewModel
    
    @State private var title = ""
    @State private var amount = ""
    @State private var selectedCategory = ExpenseCategory.food
    @State private var date = Date()
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("Enter expense title", text: $title)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Amount
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Amount")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("0.00", text: $amount)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
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
                        }
                        
                        // Date
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            DatePicker("", selection: $date, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .colorScheme(.dark)
                                .padding()
                                .background(Color.glassBackground)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.glassBorder, lineWidth: 1)
                                )
                        }
                        
                        // Notes
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes (Optional)")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("Add notes", text: $notes)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Update Button
                        Button(action: updateExpense) {
                            Text("Update Expense")
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
            .navigationTitle("Edit Expense")
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
                title = expense.title
                amount = String(expense.amount)
                selectedCategory = expense.category
                date = expense.date
                notes = expense.notes
            }
        }
    }
    
    private var isValid: Bool {
        !title.isEmpty && Double(amount) != nil && Double(amount)! > 0
    }
    
    private func updateExpense() {
        guard let amountValue = Double(amount) else { return }
        var updatedExpense = expense
        updatedExpense.title = title
        updatedExpense.amount = amountValue
        updatedExpense.category = selectedCategory
        updatedExpense.date = date
        updatedExpense.notes = notes
        viewModel.updateExpense(updatedExpense)
        dismiss()
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 17))
            .foregroundColor(.white)
            .padding()
            .background(Color.glassBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.glassBorder, lineWidth: 1)
            )
    }
}

