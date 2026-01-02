import SwiftUI
import SwiftData

struct QuestBookView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    @Query private var achievements: [Achievement]
    @Query private var quests: [DailyQuest]
    
    private var hasClaimableAchievements: Bool {
        achievements.contains { $0.canClaim }
    }
    
    private var hasClaimableQuests: Bool {
        let today = DailyQuest.normalizeToDay(Date())
        return quests.contains { quest in
            DailyQuest.normalizeToDay(quest.date) == today && quest.canClaim
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                tabSelector
                
                TabView(selection: $selectedTab) {
                    AchievementsView()
                        .tag(0)
                    
                    DailyQuestsView()
                        .tag(1)
                    
                    DailyLoginView()
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Quest Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            QuestBookTabButton(title: "Achievements", isSelected: selectedTab == 0, hasClaimable: hasClaimableAchievements) {
                withAnimation { selectedTab = 0 }
            }
            
            QuestBookTabButton(title: "Daily Quests", isSelected: selectedTab == 1, hasClaimable: hasClaimableQuests) {
                withAnimation { selectedTab = 1 }
            }
            
            QuestBookTabButton(title: "Daily Login", isSelected: selectedTab == 2, hasClaimable: false) {
                withAnimation { selectedTab = 2 }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
}

// MARK: - Tab Button Component

struct QuestBookTabButton: View {
    let title: String
    let isSelected: Bool
    let hasClaimable: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Text(title)
                    .font(.caption)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundColor(isSelected ? .white : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(isSelected ? Color.appAccent : Color.clear)
                    .cornerRadius(8)
                
                if hasClaimable {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Image(systemName: "exclamationmark")
                                .font(.system(size: 7, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .offset(x: -4, y: 2)
                }
            }
        }
    }
}
