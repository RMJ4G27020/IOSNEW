import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var expenseManager: ExpenseManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Section with Gamification
                    welcomeSection
                    
                    // Quick Stats
                    quickStatsSection
                    
                    // Recent Expenses
                    recentExpensesSection
                    
                    // Budget Overview
                    budgetOverviewSection
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("¡Hola!")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Nivel \(expenseManager.userProfile.level)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Level progress
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(expenseManager.userProfile.totalPoints) pts")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    ProgressView(value: expenseManager.userProfile.levelProgress)
                        .progressViewStyle(LinearProgressViewStyle())
                        .frame(width: 100)
                }
            }
            
            // Current streak
            if expenseManager.userProfile.currentStreak > 0 {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(expenseManager.userProfile.currentStreak) días de racha")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.1))
        )
    }
    
    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Resumen del Mes")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Gastos del Mes",
                    value: String(format: "%.2f", expenseManager.getMonthlyExpenses()),
                    icon: "creditcard.fill",
                    color: .red
                )
                
                StatCard(
                    title: "Gastos de la Semana",
                    value: String(format: "%.2f", expenseManager.getWeeklyExpenses()),
                    icon: "calendar.badge.clock",
                    color: .orange
                )
            }
        }
    }
    
    private var recentExpensesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Gastos Recientes")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                NavigationLink("Ver Todo", destination: ExpensesListView())
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            
            if expenseManager.expenses.isEmpty {
                EmptyStateView(
                    icon: "creditcard",
                    title: "No hay gastos registrados",
                    subtitle: "Comienza registrando tu primer gasto"
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(Array(expenseManager.expenses.prefix(3))) { expense in
                        ExpenseRowView(expense: expense)
                    }
                }
            }
        }
    }
    
    private var budgetOverviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Presupuestos")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                NavigationLink("Gestionar", destination: BudgetManagementView())
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            
            if expenseManager.budgets.isEmpty {
                EmptyStateView(
                    icon: "chart.bar.fill",
                    title: "No hay presupuestos configurados",
                    subtitle: "Crea un presupuesto para controlar tus gastos"
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(expenseManager.budgets.prefix(2)) { budget in
                        BudgetProgressView(budget: budget)
                    }
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                Spacer()
            }
            
            Text("$\(value)")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(.gray)
            
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    DashboardView()
        .environmentObject(ExpenseManager())
}
