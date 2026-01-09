//
//  InvestmentView.swift
//  Pocket Finance Smart Capital
//
//  Created by Simon Bakhanets on 09.01.2026.
//

import SwiftUI

struct InvestmentView: View {
    @StateObject private var viewModel = InvestmentViewModel()
    @State private var selectedInvestment: IdentifiableInvestment?
    @State private var showingAddInvestment = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: Constants.sectionSpacing) {
                // Header
                headerSection
                
                // Portfolio Summary
                portfolioSummarySection
                
                // Performance Card
                performanceCardSection
                
                // Investments List
                investmentsListSection
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
        .sheet(isPresented: $showingAddInvestment) {
            AddInvestmentView(viewModel: viewModel)
        }
        .sheet(item: $selectedInvestment) { identifiableInvestment in
            EditInvestmentView(investment: identifiableInvestment.investment, viewModel: viewModel)
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Investments")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                
                Text("\(viewModel.investments.count) holdings")
                    .font(.system(size: 17))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Button(action: {
                showingAddInvestment = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.appGreen)
            }
        }
    }
    
    // MARK: - Portfolio Summary Section
    
    private var portfolioSummarySection: some View {
        GlassCard {
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(.appGreen)
                    Text("Portfolio Value")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                }
                
                HStack(alignment: .bottom, spacing: 8) {
                    Text("\(Constants.currencySymbol)\(viewModel.totalValue, specifier: "%.2f")")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Performance Card Section
    
    private var performanceCardSection: some View {
        HStack(spacing: 12) {
            // Total Cost
            GlassCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total Cost")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("\(Constants.currencySymbol)\(viewModel.totalCost, specifier: "%.2f")")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Gain/Loss
            GlassCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Gain/Loss")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(viewModel.totalGainLoss >= 0 ? "+" : "")\(Constants.currencySymbol)\(viewModel.totalGainLoss, specifier: "%.2f")")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(viewModel.totalGainLoss >= 0 ? .appGreen : .appRed)
                        
                        Text("\(viewModel.totalGainLossPercentage >= 0 ? "+" : "")\(viewModel.totalGainLossPercentage, specifier: "%.2f")%")
                            .font(.system(size: 13))
                            .foregroundColor(viewModel.totalGainLossPercentage >= 0 ? .appGreen : .appRed)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    // MARK: - Investments List Section
    
    private var investmentsListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "list.bullet")
                    .foregroundColor(.appGreen)
                Text("Holdings")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }
            
            if viewModel.investments.isEmpty {
                emptyStateView
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.investments) { investment in
                        InvestmentCard(investment: investment) {
                            selectedInvestment = IdentifiableInvestment(investment: investment)
                        } onDelete: {
                            viewModel.deleteInvestment(investment)
                        }
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        GlassCard {
            VStack(spacing: 16) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 50))
                    .foregroundColor(.white.opacity(0.3))
                
                Text("No investments yet")
                    .font(.system(size: 17))
                    .foregroundColor(.white.opacity(0.7))
                
                Text("Tap the + button to add your first investment")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 40)
        }
    }
}

// MARK: - Supporting Views

struct InvestmentCard: View {
    let investment: Investment
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        GlassCard {
            VStack(spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(investment.symbol)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(investment.name)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.6))
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(Constants.currencySymbol)\(investment.currentPrice, specifier: "%.2f")")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("\(investment.gainLossPercentage >= 0 ? "+" : "")\(investment.gainLossPercentage, specifier: "%.2f")%")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(investment.gainLoss >= 0 ? .appGreen : .appRed)
                    }
                }
                
                // Details
                HStack {
                    InvestmentDetailItem(label: "Shares", value: String(format: "%.2f", investment.shares))
                    
                    Spacer()
                    
                    InvestmentDetailItem(label: "Total Value", value: "\(Constants.currencySymbol)\(String(format: "%.2f", investment.totalValue))")
                    
                    Spacer()
                    
                    InvestmentDetailItem(
                        label: "Gain/Loss",
                        value: "\(investment.gainLoss >= 0 ? "+" : "")\(Constants.currencySymbol)\(String(format: "%.2f", investment.gainLoss))",
                        valueColor: investment.gainLoss >= 0 ? .appGreen : .appRed
                    )
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

struct InvestmentDetailItem: View {
    let label: String
    let value: String
    var valueColor: Color = .white
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.5))
            
            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}

struct IdentifiableInvestment: Identifiable {
    let id = UUID()
    let investment: Investment
}

// MARK: - Add Investment View

struct AddInvestmentView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: InvestmentViewModel
    
    @State private var symbol = ""
    @State private var name = ""
    @State private var shares = ""
    @State private var purchasePrice = ""
    @State private var currentPrice = ""
    @State private var purchaseDate = Date()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Symbol
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Symbol")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("e.g., AAPL", text: $symbol)
                                .textFieldStyle(CustomTextFieldStyle())
                                .autocapitalization(.allCharacters)
                        }
                        
                        // Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("e.g., Apple Inc.", text: $name)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Shares
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Shares")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("0.00", text: $shares)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Purchase Price
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Purchase Price")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("0.00", text: $purchasePrice)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Current Price
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Current Price")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("0.00", text: $currentPrice)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Purchase Date
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Purchase Date")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            DatePicker("", selection: $purchaseDate, displayedComponents: .date)
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
                        
                        // Add Button
                        Button(action: addInvestment) {
                            Text("Add Investment")
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
            .navigationTitle("Add Investment")
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
        !symbol.isEmpty &&
        !name.isEmpty &&
        Double(shares) != nil && Double(shares)! > 0 &&
        Double(purchasePrice) != nil && Double(purchasePrice)! > 0 &&
        Double(currentPrice) != nil && Double(currentPrice)! > 0
    }
    
    private func addInvestment() {
        guard let sharesValue = Double(shares),
              let purchasePriceValue = Double(purchasePrice),
              let currentPriceValue = Double(currentPrice) else { return }
        
        viewModel.addInvestment(
            symbol: symbol.uppercased(),
            name: name,
            shares: sharesValue,
            purchasePrice: purchasePriceValue,
            currentPrice: currentPriceValue,
            purchaseDate: purchaseDate
        )
        dismiss()
    }
}

// MARK: - Edit Investment View

struct EditInvestmentView: View {
    @Environment(\.dismiss) var dismiss
    let investment: Investment
    @ObservedObject var viewModel: InvestmentViewModel
    
    @State private var symbol = ""
    @State private var name = ""
    @State private var shares = ""
    @State private var purchasePrice = ""
    @State private var currentPrice = ""
    @State private var purchaseDate = Date()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Symbol
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Symbol")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("e.g., AAPL", text: $symbol)
                                .textFieldStyle(CustomTextFieldStyle())
                                .autocapitalization(.allCharacters)
                        }
                        
                        // Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("e.g., Apple Inc.", text: $name)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Shares
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Shares")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("0.00", text: $shares)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Purchase Price
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Purchase Price")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("0.00", text: $purchasePrice)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Current Price
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Current Price")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("0.00", text: $currentPrice)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Purchase Date
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Purchase Date")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            DatePicker("", selection: $purchaseDate, displayedComponents: .date)
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
                        
                        // Update Button
                        Button(action: updateInvestment) {
                            Text("Update Investment")
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
            .navigationTitle("Edit Investment")
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
                symbol = investment.symbol
                name = investment.name
                shares = String(investment.shares)
                purchasePrice = String(investment.purchasePrice)
                currentPrice = String(investment.currentPrice)
                purchaseDate = investment.purchaseDate
            }
        }
    }
    
    private var isValid: Bool {
        !symbol.isEmpty &&
        !name.isEmpty &&
        Double(shares) != nil && Double(shares)! > 0 &&
        Double(purchasePrice) != nil && Double(purchasePrice)! > 0 &&
        Double(currentPrice) != nil && Double(currentPrice)! > 0
    }
    
    private func updateInvestment() {
        guard let sharesValue = Double(shares),
              let purchasePriceValue = Double(purchasePrice),
              let currentPriceValue = Double(currentPrice) else { return }
        
        var updatedInvestment = investment
        updatedInvestment.symbol = symbol.uppercased()
        updatedInvestment.name = name
        updatedInvestment.shares = sharesValue
        updatedInvestment.purchasePrice = purchasePriceValue
        updatedInvestment.currentPrice = currentPriceValue
        updatedInvestment.purchaseDate = purchaseDate
        
        viewModel.updateInvestment(updatedInvestment)
        dismiss()
    }
}

