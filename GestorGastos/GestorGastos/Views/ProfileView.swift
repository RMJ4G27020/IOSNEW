import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var expenseManager: ExpenseManager
    @State private var showingBadgeDetail: Badge?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header with Level and Points
                    profileHeaderSection
                    
                    // Progress and Achievements
                    progressSection
                    
                    // Badges Section
                    badgesSection
                    
                    // Statistics
                    statisticsSection
                    
                    // Settings
                    settingsSection
                }
                .padding()
            }
            .navigationTitle("Perfil")
        }
        .sheet(item: $showingBadgeDetail) { badge in
            BadgeDetailView(badge: badge)
        }
    }
    
    private var profileHeaderSection: some View {
        VStack(spacing: 16) {
            // Avatar and Level
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 100, height: 100)
                    
                    Text("\(expenseManager.userProfile.level)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Text("Nivel \(expenseManager.userProfile.level)")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("\(expenseManager.userProfile.totalPoints) Puntos")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            
            // Level Progress
            VStack(spacing: 8) {
                HStack {
                    Text("Progreso al siguiente nivel")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(expenseManager.userProfile.experiencePoints)/\(expenseManager.userProfile.nextLevelPoints)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                ProgressView(value: expenseManager.userProfile.levelProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Progreso")
                .font(.title2)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ProgressCard(
                    title: "Racha Actual",
                    value: "\(expenseManager.userProfile.currentStreak)",
                    subtitle: "días",
                    icon: "flame.fill",
                    color: .orange
                )
                
                ProgressCard(
                    title: "Mejor Racha",
                    value: "\(expenseManager.userProfile.longestStreak)",
                    subtitle: "días",
                    icon: "trophy.fill",
                    color: .gold
                )
                
                ProgressCard(
                    title: "Gastos Registrados",
                    value: "\(expenseManager.userProfile.totalExpensesLogged)",
                    subtitle: "total",
                    icon: "list.number",
                    color: .green
                )
                
                ProgressCard(
                    title: "Insignias",
                    value: "\(expenseManager.userProfile.badges.filter { $0.isUnlocked }.count)",
                    subtitle: "desbloqueadas",
                    icon: "star.fill",
                    color: .purple
                )
            }
        }
    }
    
    private var badgesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Insignias")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(expenseManager.userProfile.badges.filter { $0.isUnlocked }.count)/\(Achievement.allCases.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                ForEach(Achievement.allCases, id: \.self) { achievement in
                    let badge = expenseManager.userProfile.badges.first { $0.title == achievement.badge.title } ?? achievement.badge
                    
                    BadgeView(badge: badge, achievement: achievement) {
                        showingBadgeDetail = badge
                    }
                }
            }
        }
    }
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Estadísticas")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                StatisticRow(
                    icon: "calendar.badge.plus",
                    title: "Miembro desde",
                    value: DateFormatter.monthYear.string(from: expenseManager.userProfile.joinDate)
                )
                
                StatisticRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Gasto promedio diario",
                    value: "$\(expenseManager.getWeeklyExpenses() / 7, specifier: "%.2f")"
                )
                
                StatisticRow(
                    icon: "folder.fill",
                    title: "Categorías favoritas",
                    value: getMostUsedCategory()
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Configuración")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "bell.fill",
                    title: "Notificaciones",
                    subtitle: "Recordatorios y alertas"
                ) {
                    // Implement notifications settings
                }
                
                Divider()
                
                SettingsRow(
                    icon: "icloud.fill",
                    title: "Sincronización",
                    subtitle: "Respaldar datos en iCloud"
                ) {
                    // Implement iCloud sync
                }
                
                Divider()
                
                SettingsRow(
                    icon: "questionmark.circle.fill",
                    title: "Ayuda y Soporte",
                    subtitle: "FAQ y contacto"
                ) {
                    // Implement help
                }
                
                Divider()
                
                SettingsRow(
                    icon: "info.circle.fill",
                    title: "Acerca de",
                    subtitle: "Versión y información"
                ) {
                    // Implement about
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
    
    private func getMostUsedCategory() -> String {
        let categoryTotals = expenseManager.getExpensesByCategory()
        if let mostUsed = categoryTotals.max(by: { $0.value < $1.value }) {
            return mostUsed.key.rawValue
        }
        return "N/A"
    }
}

struct ProgressCard: View {
    let title: String
    let value: String
    let subtitle: String
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
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct BadgeView: View {
    let badge: Badge
    let achievement: Achievement
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(badge.isUnlocked ? 
                              LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing) :
                              Color.gray.opacity(0.3))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: badge.icon)
                        .font(.title2)
                        .foregroundColor(badge.isUnlocked ? .white : .gray)
                }
                
                Text(badge.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(badge.isUnlocked ? .primary : .secondary)
                
                if !badge.isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StatisticRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct BadgeDetailView: View {
    let badge: Badge
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Badge Icon
                ZStack {
                    Circle()
                        .fill(badge.isUnlocked ? 
                              LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing) :
                              Color.gray.opacity(0.3))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: badge.icon)
                        .font(.system(size: 40))
                        .foregroundColor(badge.isUnlocked ? .white : .gray)
                }
                
                VStack(spacing: 12) {
                    Text(badge.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(badge.description)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                
                if let unlockedDate = badge.unlockedDate {
                    Text("Desbloqueada el \(DateFormatter.medium.string(from: unlockedDate))")
                        .font(.subheadline)
                        .foregroundColor(.green)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                } else {
                    Text("Aún no desbloqueada")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Insignia")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Extensions

extension Color {
    static let gold = Color(red: 255/255, green: 215/255, blue: 0/255)
}

extension DateFormatter {
    static let medium: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    static let monthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }()
}

#Preview {
    ProfileView()
        .environmentObject(ExpenseManager())
}
