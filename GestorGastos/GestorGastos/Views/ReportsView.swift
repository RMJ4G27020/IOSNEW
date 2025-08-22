import SwiftUI
import Charts

struct ReportsView: View {
    @EnvironmentObject var expenseManager: ExpenseManager
    @State private var selectedPeriod: TimePeriod = .month
    @State private var selectedReportType: ReportType = .category
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Period Selection
                    periodSelectionSection
                    
                    // Report Type Selection
                    reportTypeSelection
                    
                    // Charts Section
                    chartsSection
                    
                    // Summary Statistics
                    summarySection
                }
                .padding()
            }
            .navigationTitle("Reportes")
        }
    }
    
    private var periodSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Período")
                .font(.headline)
                .fontWeight(.semibold)
            
            Picker("Período", selection: $selectedPeriod) {
                ForEach(TimePeriod.allCases, id: \.self) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var reportTypeSelection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tipo de Reporte")
                .font(.headline)
                .fontWeight(.semibold)
            
            Picker("Tipo", selection: $selectedReportType) {
                ForEach(ReportType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var chartsSection: some View {
        VStack(spacing: 20) {
            switch selectedReportType {
            case .category:
                categoryChart
            case .trend:
                trendChart
            case .budget:
                budgetChart
            }
        }
    }
    
    private var categoryChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Gastos por Categoría")
                .font(.title2)
                .fontWeight(.semibold)
            
            let categoryData = getCategoryData()
            
            if categoryData.isEmpty {
                EmptyStateView(
                    icon: "chart.pie",
                    title: "No hay datos suficientes",
                    subtitle: "Registra gastos para ver el análisis por categorías"
                )
            } else {
                Chart(categoryData, id: \.category) { item in
                    SectorMark(
                        angle: .value("Amount", item.amount),
                        innerRadius: .ratio(0.5)
                    )
                    .foregroundStyle(item.category.color)
                }
                .frame(height: 250)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(categoryData, id: \.category) { item in
                        CategoryLegendItem(
                            category: item.category,
                            amount: item.amount,
                            percentage: item.percentage
                        )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
    
    private var trendChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tendencia de Gastos")
                .font(.title2)
                .fontWeight(.semibold)
            
            let trendData = getTrendData()
            
            if trendData.isEmpty {
                EmptyStateView(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "No hay datos suficientes",
                    subtitle: "Registra gastos durante varios días para ver la tendencia"
                )
            } else {
                Chart(trendData, id: \.date) { item in
                    LineMark(
                        x: .value("Date", item.date),
                        y: .value("Amount", item.amount)
                    )
                    .foregroundStyle(.blue)
                    
                    AreaMark(
                        x: .value("Date", item.date),
                        y: .value("Amount", item.amount)
                    )
                    .foregroundStyle(.blue.opacity(0.3))
                }
                .frame(height: 200)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
    
    private var budgetChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Estado de Presupuestos")
                .font(.title2)
                .fontWeight(.semibold)
            
            if expenseManager.budgets.isEmpty {
                EmptyStateView(
                    icon: "chart.bar",
                    title: "No hay presupuestos configurados",
                    subtitle: "Crea presupuestos para ver el análisis de cumplimiento"
                )
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(expenseManager.budgets) { budget in
                        BudgetProgressView(budget: budget)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
    
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Resumen")
                .font(.title2)
                .fontWeight(.semibold)
            
            let totalAmount = getTotalForPeriod()
            let averageDaily = getAverageDaily()
            let transactionCount = getTransactionCount()
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                SummaryCard(
                    title: "Total Gastado",
                    value: "$\(totalAmount, specifier: "%.2f")",
                    icon: "dollarsign.circle.fill",
                    color: .blue
                )
                
                SummaryCard(
                    title: "Promedio Diario",
                    value: "$\(averageDaily, specifier: "%.2f")",
                    icon: "calendar.circle.fill",
                    color: .green
                )
                
                SummaryCard(
                    title: "Transacciones",
                    value: "\(transactionCount)",
                    icon: "list.number",
                    color: .orange
                )
                
                SummaryCard(
                    title: "Categorías Usadas",
                    value: "\(getUsedCategoriesCount())",
                    icon: "folder.circle.fill",
                    color: .purple
                )
            }
        }
    }
    
    // MARK: - Data Processing Methods
    
    private func getCategoryData() -> [CategoryChartData] {
        let categoryTotals = expenseManager.getExpensesByCategory()
        let total = categoryTotals.values.reduce(0, +)
        
        return categoryTotals.map { category, amount in
            CategoryChartData(
                category: category,
                amount: amount,
                percentage: total > 0 ? (amount / total) * 100 : 0
            )
        }.sorted { $0.amount > $1.amount }
    }
    
    private func getTrendData() -> [TrendChartData] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -30, to: endDate) ?? endDate
        
        var dailyTotals: [Date: Double] = [:]
        
        for expense in expenseManager.expenses {
            if expense.date >= startDate && expense.date <= endDate {
                let day = calendar.startOfDay(for: expense.date)
                dailyTotals[day, default: 0] += expense.amount
            }
        }
        
        return dailyTotals.map { date, amount in
            TrendChartData(date: date, amount: amount)
        }.sorted { $0.date < $1.date }
    }
    
    private func getTotalForPeriod() -> Double {
        switch selectedPeriod {
        case .week:
            return expenseManager.getWeeklyExpenses()
        case .month:
            return expenseManager.getMonthlyExpenses()
        case .year:
            let calendar = Calendar.current
            let yearExpenses = expenseManager.expenses.filter { expense in
                calendar.isDate(expense.date, equalTo: Date(), toGranularity: .year)
            }
            return yearExpenses.reduce(0) { $0 + $1.amount }
        }
    }
    
    private func getAverageDaily() -> Double {
        let total = getTotalForPeriod()
        let days = selectedPeriod.days
        return days > 0 ? total / Double(days) : 0
    }
    
    private func getTransactionCount() -> Int {
        let calendar = Calendar.current
        let now = Date()
        
        return expenseManager.expenses.filter { expense in
            switch selectedPeriod {
            case .week:
                return calendar.isDate(expense.date, equalTo: now, toGranularity: .weekOfYear)
            case .month:
                return calendar.isDate(expense.date, equalTo: now, toGranularity: .month)
            case .year:
                return calendar.isDate(expense.date, equalTo: now, toGranularity: .year)
            }
        }.count
    }
    
    private func getUsedCategoriesCount() -> Int {
        let calendar = Calendar.current
        let now = Date()
        
        let filteredExpenses = expenseManager.expenses.filter { expense in
            switch selectedPeriod {
            case .week:
                return calendar.isDate(expense.date, equalTo: now, toGranularity: .weekOfYear)
            case .month:
                return calendar.isDate(expense.date, equalTo: now, toGranularity: .month)
            case .year:
                return calendar.isDate(expense.date, equalTo: now, toGranularity: .year)
            }
        }
        
        return Set(filteredExpenses.map { $0.category }).count
    }
}

// MARK: - Supporting Types and Views

enum TimePeriod: String, CaseIterable {
    case week = "Semana"
    case month = "Mes"
    case year = "Año"
    
    var days: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .year: return 365
        }
    }
}

enum ReportType: String, CaseIterable {
    case category = "Categorías"
    case trend = "Tendencia"
    case budget = "Presupuestos"
}

struct CategoryChartData {
    let category: ExpenseCategory
    let amount: Double
    let percentage: Double
}

struct TrendChartData {
    let date: Date
    let amount: Double
}

struct CategoryLegendItem: View {
    let category: ExpenseCategory
    let amount: Double
    let percentage: Double
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(category.color)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text("\(percentage, specifier: "%.1f")%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("$\(amount, specifier: "%.0f")")
                .font(.caption)
                .fontWeight(.semibold)
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct BudgetProgressView: View {
    let budget: Budget
    @EnvironmentObject var expenseManager: ExpenseManager
    
    var spentAmount: Double {
        expenseManager.getBudgetSpent(for: budget.category, in: budget.period)
    }
    
    var progress: Double {
        budget.limit > 0 ? min(spentAmount / budget.limit, 1.0) : 0
    }
    
    var progressColor: Color {
        if progress < 0.7 { return .green }
        if progress < 0.9 { return .orange }
        return .red
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: budget.category.icon)
                    .foregroundColor(budget.category.color)
                    .font(.title3)
                
                Text(budget.category.rawValue)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(budget.period.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            
            HStack {
                Text("$\(spentAmount, specifier: "%.2f")")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(progressColor)
                
                Text("de $\(budget.limit, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(progress * 100, specifier: "%.0f")%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                .scaleEffect(x: 1, y: 1.5, anchor: .center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(progressColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    ReportsView()
        .environmentObject(ExpenseManager())
}
