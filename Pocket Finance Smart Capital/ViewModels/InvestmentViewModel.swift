//
//  InvestmentViewModel.swift
//  Pocket Finance Smart Capital
//
//  Created by Simon Bakhanets on 09.01.2026.
//

import Foundation
import Combine

class InvestmentViewModel: ObservableObject {
    @Published var investments: [Investment] = []
    @Published var totalValue: Double = 0
    @Published var totalCost: Double = 0
    @Published var totalGainLoss: Double = 0
    @Published var totalGainLossPercentage: Double = 0
    
    private let dataService = FinanceDataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupObservers()
        updateData()
    }
    
    private func setupObservers() {
        dataService.$investments
            .sink { [weak self] _ in
                self?.updateData()
            }
            .store(in: &cancellables)
    }
    
    func updateData() {
        investments = dataService.investments.sorted(by: { $0.symbol < $1.symbol })
        totalValue = dataService.getTotalInvestmentValue()
        totalCost = dataService.getTotalInvestmentCost()
        totalGainLoss = dataService.getTotalGainLoss()
        
        if totalCost > 0 {
            totalGainLossPercentage = (totalGainLoss / totalCost) * 100
        } else {
            totalGainLossPercentage = 0
        }
    }
    
    func addInvestment(symbol: String, name: String, shares: Double, purchasePrice: Double, currentPrice: Double, purchaseDate: Date) {
        let investment = Investment(symbol: symbol, name: name, shares: shares, purchasePrice: purchasePrice, currentPrice: currentPrice, purchaseDate: purchaseDate)
        dataService.addInvestment(investment)
    }
    
    func updateInvestment(_ investment: Investment) {
        dataService.updateInvestment(investment)
    }
    
    func deleteInvestment(_ investment: Investment) {
        dataService.deleteInvestment(investment)
    }
}

