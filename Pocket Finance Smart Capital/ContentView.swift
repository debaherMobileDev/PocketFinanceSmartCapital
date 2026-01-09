//
//  ContentView.swift
//  Pocket Finance Smart Capital
//
//  Created by Simon Bakhanets on 09.01.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @AppStorage(Constants.hasCompletedOnboarding) var hasCompletedOnboarding = false
    
    var body: some View {
        Group {
            if hasCompletedOnboarding {
                mainTabView
            } else {
                OnboardingView()
            }
        }
        .onAppear {
            #if DEBUG
            // Загружаем тестовые данные при первом запуске
            if hasCompletedOnboarding {
                SeedData.loadSampleData()
            }
            #endif
        }
    }
    
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
                .tag(0)
            
            ExpenseTrackerView()
                .tabItem {
                    Label("Expenses", systemImage: "creditcard.fill")
                }
                .tag(1)
            
            InvestmentView()
                .tabItem {
                    Label("Investments", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(2)
            
            BudgetPlannerView()
                .tabItem {
                    Label("Budgets", systemImage: "chart.pie.fill")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .accentColor(.appGreen)
        .onAppear {
            // Улучшаем видимость неактивных иконок в TabBar
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            
            // Фон TabBar
            appearance.backgroundColor = UIColor(Color.appSecondaryBackground.opacity(0.95))
            
            // Активная иконка (зеленая)
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.appGreen)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor(Color.appGreen)
            ]
            
            // Неактивная иконка (светло-серая, хорошо видимая)
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.white.opacity(0.6))
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor(Color.white.opacity(0.6))
            ]
            
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @AppStorage(Constants.hasCompletedOnboarding) var hasCompletedOnboarding = false
    @State private var showingResetAlert = false
    @State private var showingSeedAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.appBackground, Color.appSecondaryBackground]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Constants.sectionSpacing) {
                        // App Info
                        GlassCard {
                            VStack(spacing: 16) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.appGreen)
                                
                                Text("Pocket Finance Smart Capital")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                
                                Text("Version 1.0.0")
                                    .font(.system(size: 15))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .padding(.vertical, 20)
                        }
                        
                        // Debug Actions
                        #if DEBUG
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Debug Tools")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.horizontal, 4)
                            
                            SettingsButton(
                                title: "Load Sample Data",
                                icon: "square.and.arrow.down.fill",
                                color: .appGreen
                            ) {
                                showingSeedAlert = true
                            }
                        }
                        #endif
                        
                        // Actions
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Data Management")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.horizontal, 4)
                            
                            SettingsButton(
                                title: "Reset All Data",
                                icon: "trash.fill",
                                color: .appRed
                            ) {
                                showingResetAlert = true
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Reset All Data", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("This will permanently delete all your expenses, investments, and budgets. This action cannot be undone.")
            }
            .alert("Load Sample Data", isPresented: $showingSeedAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Load", role: .none) {
                    loadSampleData()
                }
            } message: {
                Text("This will add sample expenses, investments, and budgets to your app for testing purposes.")
            }
        }
    }
    
    private func resetAllData() {
        FinanceDataService.shared.resetAllData()
        hasCompletedOnboarding = false
    }
    
    private func loadSampleData() {
        #if DEBUG
        SeedData.loadSampleData()
        #endif
    }
}

struct SettingsButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding()
            .background(Color.glassBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.glassBorder, lineWidth: 1)
            )
        }
    }
}

#Preview {
    ContentView()
}
