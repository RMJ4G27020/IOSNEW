import SwiftUI

struct BudgetManagementView: View {
    @EnvironmentObject var expenseManager: ExpenseManager
    @State private var showingAddBudget = false
    
    var body: some View {
        NavigationView {
            VStack {
                if expenseManager.budgets.isEmpty {
                    EmptyStateView(
                        icon: "chart.bar.fill",
                        title: "No hay presupuestos configurados",
                        subtitle: "Crea tu primer presupuesto para controlar tus gastos"
                    )
                    .padding()
                } else {
                    List {
                        ForEach(expenseManager.budgets) { budget in
                            BudgetRowView(budget: budget)
                                .swipeActions(edge: .trailing) {
                                    Button("Eliminar", role: .destructive) {
                                        expenseManager.deleteBudget(budget)
                                    }
                                }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Presupuestos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddBudget = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddBudget) {
                AddBudgetView()
            }
        }
    }
}

struct BudgetRowView: View {
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
    
    var remainingAmount: Double {
        budget.limit - spentAmount
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: budget.category.icon)
                    .foregroundColor(budget.category.color)
                    .font(.title2)
                    .frame(width: 32, height: 32)
                    .background(budget.category.color.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(budget.category.rawValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(budget.period.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(spentAmount, specifier: "%.2f")")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(progressColor)
                    
                    Text("de $\(budget.limit, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(spacing: 8) {
                HStack {
                    Text("Progreso")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(progress * 100, specifier: "%.0f")%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(progressColor)
                }
                
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
            }
            
            HStack {
                if remainingAmount > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Quedan $\(remainingAmount, specifier: "%.2f")")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text("Excedido por $\(abs(remainingAmount), specifier: "%.2f")")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(progressColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct AddBudgetView: View {
    @EnvironmentObject var expenseManager: ExpenseManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCategory: ExpenseCategory = .food
    @State private var limitAmount: String = ""
    @State private var selectedPeriod: BudgetPeriod = .monthly
    
    var body: some View {
        NavigationView {
            Form {
                Section("Configuración del Presupuesto") {
                    Picker("Categoría", selection: $selectedCategory) {
                        ForEach(ExpenseCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    
                    TextField("Límite del presupuesto", text: $limitAmount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                    
                    Picker("Período", selection: $selectedPeriod) {
                        ForEach(BudgetPeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                }
                
                Section("Vista Previa") {
                    if let limit = Double(limitAmount), limit > 0 {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: selectedCategory.icon)
                                    .foregroundColor(selectedCategory.color)
                                
                                Text(selectedCategory.rawValue)
                                    .font(.headline)
                                
                                Spacer()
                                
                                Text(selectedPeriod.rawValue)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            
                            Text("Límite: $\(limit, specifier: "%.2f")")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedCategory.color.opacity(0.1))
                        )
                    } else {
                        Text("Ingresa un monto válido para ver la vista previa")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Nuevo Presupuesto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveBudget()
                    }
                    .disabled(limitAmount.isEmpty || Double(limitAmount) == nil || Double(limitAmount)! <= 0)
                }
            }
        }
    }
    
    private func saveBudget() {
        guard let limit = Double(limitAmount), limit > 0 else { return }
        
        let newBudget = Budget(
            category: selectedCategory,
            limit: limit,
            period: selectedPeriod
        )
        
        expenseManager.addBudget(newBudget)
        dismiss()
    }
}

#Preview {
    BudgetManagementView()
        .environmentObject(ExpenseManager())
}

#Preview("Add Budget") {
    AddBudgetView()
        .environmentObject(ExpenseManager())
}
