import SwiftUI

struct ExpensesListView: View {
    @EnvironmentObject var expenseManager: ExpenseManager
    @State private var searchText = ""
    @State private var selectedCategory: ExpenseCategory?
    @State private var showingAddExpense = false
    
    var filteredExpenses: [Expense] {
        var expenses = expenseManager.expenses.sorted { $0.date > $1.date }
        
        if !searchText.isEmpty {
            expenses = expenses.filter { expense in
                expense.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let category = selectedCategory {
            expenses = expenses.filter { $0.category == category }
        }
        
        return expenses
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        CategoryFilterChip(
                            title: "Todos",
                            isSelected: selectedCategory == nil,
                            action: { selectedCategory = nil }
                        )
                        
                        ForEach(ExpenseCategory.allCases, id: \.self) { category in
                            CategoryFilterChip(
                                title: category.rawValue,
                                icon: category.icon,
                                color: category.color,
                                isSelected: selectedCategory == category,
                                action: { selectedCategory = category }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                if filteredExpenses.isEmpty {
                    EmptyStateView(
                        icon: "creditcard",
                        title: searchText.isEmpty ? "No hay gastos registrados" : "No se encontraron gastos",
                        subtitle: searchText.isEmpty ? "Comienza registrando tu primer gasto" : "Intenta con otros términos de búsqueda"
                    )
                    .padding()
                } else {
                    List {
                        ForEach(filteredExpenses) { expense in
                            ExpenseRowView(expense: expense)
                                .swipeActions(edge: .trailing) {
                                    Button("Eliminar", role: .destructive) {
                                        expenseManager.deleteExpense(expense)
                                    }
                                }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Gastos")
            .searchable(text: $searchText, prompt: "Buscar gastos...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddExpense = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView()
            }
        }
    }
}

struct ExpenseRowView: View {
    let expense: Expense
    
    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            Image(systemName: expense.category.icon)
                .font(.title2)
                .foregroundColor(expense.category.color)
                .frame(width: 40, height: 40)
                .background(expense.category.color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.description)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack {
                    Text(expense.category.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(expense.category.color.opacity(0.2))
                        .foregroundColor(expense.category.color)
                        .clipShape(Capsule())
                    
                    Text(expense.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("$\(expense.amount, specifier: "%.2f")")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if expense.receiptImage != nil {
                    Image(systemName: "paperclip")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct CategoryFilterChip: View {
    let title: String
    let icon: String?
    let color: Color?
    let isSelected: Bool
    let action: () -> Void
    
    init(title: String, icon: String? = nil, color: Color? = nil, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.color = color
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected ? (color ?? .blue) : Color.gray.opacity(0.2))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
    }
}

#Preview {
    ExpensesListView()
        .environmentObject(ExpenseManager())
}
