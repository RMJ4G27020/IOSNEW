import Foundation
import Combine

class ExpenseManager: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var budgets: [Budget] = []
    @Published var userProfile: UserProfile = UserProfile()
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadData()
    }
    
    // MARK: - Expense Management
    func addExpense(_ expense: Expense) {
        expenses.append(expense)
        updateUserStats()
        checkAchievements()
        saveData()
    }
    
    func deleteExpense(_ expense: Expense) {
        expenses.removeAll { $0.id == expense.id }
        saveData()
    }
    
    func updateExpense(_ expense: Expense) {
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
            expenses[index] = expense
            saveData()
        }
    }
    
    // MARK: - Budget Management
    func addBudget(_ budget: Budget) {
        budgets.append(budget)
        saveData()
    }
    
    func deleteBudget(_ budget: Budget) {
        budgets.removeAll { $0.id == budget.id }
        saveData()
    }
    
    func getBudgetSpent(for category: ExpenseCategory, in period: BudgetPeriod) -> Double {
        let calendar = Calendar.current
        let now = Date()
        
        let filteredExpenses = expenses.filter { expense in
            expense.category == category &&
            calendar.dateInterval(of: periodToCalendarComponent(period), for: now)?.contains(expense.date) == true
        }
        
        return filteredExpenses.reduce(0) { $0 + $1.amount }
    }
    
    private func periodToCalendarComponent(_ period: BudgetPeriod) -> Calendar.Component {
        switch period {
        case .daily: return .day
        case .weekly: return .weekOfYear
        case .monthly: return .month
        case .yearly: return .year
        }
    }
    
    // MARK: - Analytics
    func getExpensesByCategory() -> [ExpenseCategory: Double] {
        var categoryTotals: [ExpenseCategory: Double] = [:]
        
        for expense in expenses {
            categoryTotals[expense.category, default: 0] += expense.amount
        }
        
        return categoryTotals
    }
    
    func getMonthlyExpenses() -> Double {
        let calendar = Calendar.current
        let now = Date()
        
        let monthlyExpenses = expenses.filter { expense in
            calendar.isDate(expense.date, equalTo: now, toGranularity: .month)
        }
        
        return monthlyExpenses.reduce(0) { $0 + $1.amount }
    }
    
    func getWeeklyExpenses() -> Double {
        let calendar = Calendar.current
        let now = Date()
        
        let weeklyExpenses = expenses.filter { expense in
            calendar.isDate(expense.date, equalTo: now, toGranularity: .weekOfYear)
        }
        
        return weeklyExpenses.reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - Gamification
    private func updateUserStats() {
        userProfile.totalExpensesLogged += 1
        userProfile.totalPoints += 10 // Base points for logging an expense
        
        // Update streak
        let calendar = Calendar.current
        if let lastExpenseDate = expenses.dropLast().last?.date {
            if calendar.isDate(lastExpenseDate, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()) {
                userProfile.currentStreak += 1
            } else if !calendar.isDateInToday(lastExpenseDate) {
                userProfile.currentStreak = 1
            }
        } else {
            userProfile.currentStreak = 1
        }
        
        if userProfile.currentStreak > userProfile.longestStreak {
            userProfile.longestStreak = userProfile.currentStreak
        }
        
        // Update level
        let newLevel = (userProfile.totalPoints / 1000) + 1
        if newLevel > userProfile.level {
            userProfile.level = newLevel
        }
    }
    
    private func checkAchievements() {
        var newBadges: [Badge] = []
        
        // First expense achievement
        if userProfile.totalExpensesLogged == 1 && !userProfile.badges.contains(where: { $0.title == Achievement.firstExpense.badge.title }) {
            var badge = Achievement.firstExpense.badge
            badge.isUnlocked = true
            badge.unlockedDate = Date()
            newBadges.append(badge)
            userProfile.totalPoints += Achievement.firstExpense.points
        }
        
        // Week streak achievement
        if userProfile.currentStreak >= 7 && !userProfile.badges.contains(where: { $0.title == Achievement.weekStreak.badge.title }) {
            var badge = Achievement.weekStreak.badge
            badge.isUnlocked = true
            badge.unlockedDate = Date()
            newBadges.append(badge)
            userProfile.totalPoints += Achievement.weekStreak.points
        }
        
        // Month streak achievement
        if userProfile.currentStreak >= 30 && !userProfile.badges.contains(where: { $0.title == Achievement.monthStreak.badge.title }) {
            var badge = Achievement.monthStreak.badge
            badge.isUnlocked = true
            badge.unlockedDate = Date()
            newBadges.append(badge)
            userProfile.totalPoints += Achievement.monthStreak.points
        }
        
        // Receipt scanner achievement
        let receiptsScanned = expenses.filter { $0.receiptImage != nil }.count
        if receiptsScanned >= 10 && !userProfile.badges.contains(where: { $0.title == Achievement.receiptScanner.badge.title }) {
            var badge = Achievement.receiptScanner.badge
            badge.isUnlocked = true
            badge.unlockedDate = Date()
            newBadges.append(badge)
            userProfile.totalPoints += Achievement.receiptScanner.points
        }
        
        // Category master achievement
        let usedCategories = Set(expenses.map { $0.category })
        if usedCategories.count >= ExpenseCategory.allCases.count && !userProfile.badges.contains(where: { $0.title == Achievement.categoryMaster.badge.title }) {
            var badge = Achievement.categoryMaster.badge
            badge.isUnlocked = true
            badge.unlockedDate = Date()
            newBadges.append(badge)
            userProfile.totalPoints += Achievement.categoryMaster.points
        }
        
        userProfile.badges.append(contentsOf: newBadges)
    }
    
    // MARK: - Data Persistence
    private func saveData() {
        // Save expenses
        if let expensesData = try? JSONEncoder().encode(expenses) {
            userDefaults.set(expensesData, forKey: "expenses")
        }
        
        // Save budgets
        if let budgetsData = try? JSONEncoder().encode(budgets) {
            userDefaults.set(budgetsData, forKey: "budgets")
        }
        
        // Save user profile
        if let profileData = try? JSONEncoder().encode(userProfile) {
            userDefaults.set(profileData, forKey: "userProfile")
        }
    }
    
    private func loadData() {
        // Load expenses
        if let expensesData = userDefaults.data(forKey: "expenses"),
           let loadedExpenses = try? JSONDecoder().decode([Expense].self, from: expensesData) {
            expenses = loadedExpenses
        }
        
        // Load budgets
        if let budgetsData = userDefaults.data(forKey: "budgets"),
           let loadedBudgets = try? JSONDecoder().decode([Budget].self, from: budgetsData) {
            budgets = loadedBudgets
        }
        
        // Load user profile
        if let profileData = userDefaults.data(forKey: "userProfile"),
           let loadedProfile = try? JSONDecoder().decode(UserProfile.self, from: profileData) {
            userProfile = loadedProfile
        }
    }
}
