import SwiftUI
import SwiftData

struct DailyQuestsView: View {
    @Query private var quests: [DailyQuest]
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query private var wallets: [RewardWallet]
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    private var wallet: RewardWallet? {
        wallets.first
    }
    
    private var todayQuests: [DailyQuest] {
        let today = DailyQuest.normalizeToDay(Date())
        return quests.filter { DailyQuest.normalizeToDay($0.date) == today }
            .sorted { quest1, quest2 in
                // Sort by sortOrder
                return quest1.sortOrder < quest2.sortOrder
            }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Daily Quests")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                if todayQuests.isEmpty {
                    ContentUnavailableView(
                        "No Quests Today",
                        systemImage: "list.bullet.clipboard",
                        description: Text("Daily quests will appear here")
                    )
                    .padding(.top, 60)
                } else {
                    ForEach(todayQuests) { quest in
                        DailyQuestRow(
                            quest: quest,
                            onClaim: {
                                claimQuest(quest)
                            }
                        )
                    }
                }
            }
            .padding(.vertical)
        }
        .onAppear {
            ensureDailyQuests()
        }
    }
    
    private func ensureDailyQuests() {
        let today = DailyQuest.normalizeToDay(Date())
        
        // Check if quests already exist for today
        if !quests.contains(where: { DailyQuest.normalizeToDay($0.date) == today }) {
            createDailyQuests(for: today)
        }
    }
    
    private func createDailyQuests(for date: Date) {
        // Quest 1: Log in! (Order: 0)
        let loginQuest = DailyQuest(
            title: "Daily Login",
            questDescription: "Log in to the app",
            targetCount: 1,
            currentProgress: 1, // Auto-completed since they're in the app
            rewardMinutes: 10,
            rewardXP: 25,
            questType: .dailyLogin,
            date: date,
            isCompleted: true,
            sortOrder: 0
        )
        
        // Quest 2: Finish 1 hour of work (Order: 1)
        let workQuest1 = DailyQuest(
            title: "Focused Hour",
            questDescription: "Complete 1 hour of focused work",
            targetCount: 1,
            rewardMinutes: 20,
            rewardXP: 50,
            questType: .workHour,
            date: date,
            sortOrder: 1
        )
        
        // Quest 3: Finish 3 hours of work (Order: 2)
        let workQuest3 = DailyQuest(
            title: "Power Session",
            questDescription: "Complete 3 hours of focused work",
            targetCount: 3,
            rewardMinutes: 40,
            rewardXP: 100,
            questType: .workHour,
            date: date,
            sortOrder: 2
        )
        
        modelContext.insert(loginQuest)
        modelContext.insert(workQuest1)
        modelContext.insert(workQuest3)
        
        try? modelContext.save()
    }
    
    private func claimQuest(_ quest: DailyQuest) {
        guard quest.canClaim, let profile = profile, let wallet = wallet else { return }
        
        // Award rewards
        wallet.availableMinutes += quest.rewardMinutes
        if quest.rewardXP > 0 {
            profile.addBonusExperience(quest.rewardXP, modelContext: modelContext)
        }
        
        quest.isClaimed = true
        try? modelContext.save()
    }
}

struct DailyQuestRow: View {
    @Bindable var quest: DailyQuest
    let onClaim: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Top row: Title and progress
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(quest.title)
                        .font(.headline)
                    
                    Text(quest.questDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("\(quest.currentProgress)/\(quest.targetCount)")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            
            // Rewards and claim button row
            HStack(spacing: 12) {
                // Time reward
                if quest.rewardMinutes > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.appAccent)
                        Text("\(quest.rewardMinutes) min")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.appAccent.opacity(0.2))
                    .cornerRadius(8)
                }
                
                // XP reward
                if quest.rewardXP > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.purple)
                        Text("\(quest.rewardXP) XP")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.purple.opacity(0.2))
                    .cornerRadius(8)
                }
                
                Spacer()
                
                // Claim button
                if quest.canClaim {
                    Button(action: onClaim) {
                        Text("Claim")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                } else if quest.isClaimed {
                    Text("Claimed")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                } else {
                    Text("In Progress")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                }
            }
            
            // Progress bar (only if targetCount > 1)
            if quest.targetCount > 1 {
                ProgressView(value: quest.progressPercent)
                    .tint(quest.isCompleted ? .green : .appAccent)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    DailyQuestsView()
        .modelContainer(DataStore.shared)
}
