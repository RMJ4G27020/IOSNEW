import SwiftUI

struct MainTabView: View {
    @StateObject private var expenseManager = ExpenseManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home - Dashboard
            DashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Inicio")
                }
                .tag(0)
            
            // Expenses
            ExpensesListView()
                .tabItem {
                    Image(systemName: "list.bullet.rectangle")
                    Text("Gastos")
                }
                .tag(1)
            
            // Add Expense (Plus button)
            AddExpenseView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Agregar")
                }
                .tag(2)
            
            // Reports
            ReportsView()
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Reportes")
                }
                .tag(3)
            
            // Profile/Gamification
            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    Text("Perfil")
                }
                .tag(4)
        }
        .environmentObject(expenseManager)
        .accentColor(.blue)
    }
}
