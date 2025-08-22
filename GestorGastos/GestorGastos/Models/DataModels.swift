import Foundation
import SwiftUI

// MARK: - Expense Model
struct Expense: Identifiable, Codable {
    let id = UUID()
    var amount: Double
    var description: String
    var category: ExpenseCategory
    var date: Date
    var receiptImage: Data?
    var isRecurring: Bool = false
    var tags: [String] = []
    
    init(amount: Double, description: String, category: ExpenseCategory, date: Date = Date()) {
        self.amount = amount
        self.description = description
        self.category = category
        self.date = date
    }
}

// MARK: - Expense Category
enum ExpenseCategory: String, CaseIterable, Codable {
    case food = "Alimentación"
    case transport = "Transporte"
    case entertainment = "Entretenimiento"
    case shopping = "Compras"
    case health = "Salud"
    case education = "Educación"
    case utilities = "Servicios"
    case other = "Otros"
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "car.fill"
        case .entertainment: return "tv.fill"
        case .shopping: return "bag.fill"
        case .health: return "cross.fill"
        case .education: return "book.fill"
        case .utilities: return "bolt.fill"
        case .other: return "questionmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .food: return .orange
        case .transport: return .blue
        case .entertainment: return .purple
        case .shopping: return .pink
        case .health: return .red
        case .education: return .green
        case .utilities: return .yellow
        case .other: return .gray
        }
    }
}

// MARK: - Budget Model
struct Budget: Identifiable, Codable {
    let id = UUID()
    var category: ExpenseCategory
    var limit: Double
    var period: BudgetPeriod
    var startDate: Date
    var isActive: Bool = true
    
    init(category: ExpenseCategory, limit: Double, period: BudgetPeriod) {
        self.category = category
        self.limit = limit
        self.period = period
        self.startDate = Date()
    }
}

// MARK: - Budget Period
enum BudgetPeriod: String, CaseIterable, Codable {
    case daily = "Diario"
    case weekly = "Semanal"
    case monthly = "Mensual"
    case yearly = "Anual"
    
    var days: Int {
        switch self {
        case .daily: return 1
        case .weekly: return 7
        case .monthly: return 30
        case .yearly: return 365
        }
    }
}

// MARK: - Gamification Models
struct UserProfile: Codable {
    var totalPoints: Int = 0
    var level: Int = 1
    var badges: [Badge] = []
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var totalExpensesLogged: Int = 0
    var joinDate: Date = Date()
    
    var experiencePoints: Int {
        return totalPoints % 1000
    }
    
    var nextLevelPoints: Int {
        return 1000
    }
    
    var levelProgress: Double {
        return Double(experiencePoints) / Double(nextLevelPoints)
    }
}

struct Badge: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String
    var icon: String
    var unlockedDate: Date?
    var isUnlocked: Bool = false
    
    init(title: String, description: String, icon: String) {
        self.title = title
        self.description = description
        self.icon = icon
    }
}

// MARK: - Achievement System
enum Achievement: CaseIterable {
    case firstExpense
    case weekStreak
    case monthStreak
    case budgetKeeper
    case receiptScanner
    case categoryMaster
    case savingsPro
    
    var badge: Badge {
        switch self {
        case .firstExpense:
            return Badge(title: "Primer Paso", description: "Registraste tu primer gasto", icon: "star.fill")
        case .weekStreak:
            return Badge(title: "Constancia Semanal", description: "7 días seguidos registrando gastos", icon: "calendar.fill")
        case .monthStreak:
            return Badge(title: "Mes Completo", description: "30 días seguidos registrando gastos", icon: "trophy.fill")
        case .budgetKeeper:
            return Badge(title: "Controlador de Presupuesto", description: "Mantuviste el presupuesto por un mes", icon: "checkmark.shield.fill")
        case .receiptScanner:
            return Badge(title: "Escáner Pro", description: "Escaneaste 10 recibos", icon: "camera.fill")
        case .categoryMaster:
            return Badge(title: "Organizador", description: "Usaste todas las categorías", icon: "folder.fill")
        case .savingsPro:
            return Badge(title: "Ahorrador Experto", description: "Ahorraste más del 20% de tu presupuesto", icon: "banknote.fill")
        }
    }
    
    var points: Int {
        switch self {
        case .firstExpense: return 50
        case .weekStreak: return 100
        case .monthStreak: return 300
        case .budgetKeeper: return 250
        case .receiptScanner: return 150
        case .categoryMaster: return 200
        case .savingsPro: return 500
        }
    }
}
