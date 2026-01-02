import SwiftUI
import SwiftData
import Combine

struct LeetCodeRequirementsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [AppSettings]
    @Query private var progress: [DailyProgress]
    
    @State private var username: String = ""
    @State private var dailyGoal: Int = 3
    @State private var isEnabled: Bool = false
    @State private var blocksRewards: Bool = false
    @State private var isVerifying: Bool = false
    @State private var isRefreshing: Bool = false
    @State private var verificationMessage: String = ""
    @State private var showVerificationAlert: Bool = false
    @State private var currentTime = Date()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var appSettings: AppSettings? {
        settings.first
    }
    
    private var todayProgress: DailyProgress? {
        let today = DailyProgress.normalizeToDay(Date())
        return progress.first { $0.date == today }
    }
    
    private var currentProgress: Int {
        todayProgress?.leetcodeProblems ?? 0
    }
    
    var body: some View {
        Form {
            Section(header: Text("Configuration")) {
                HStack {
                    Text("Username")
                    Spacer()
                    TextField("LeetCode username", text: $username)
                        .multilineTextAlignment(.trailing)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                }
                
                if !username.isEmpty {
                    Button(action: verifyUsername) {
                        HStack {
                            if isVerifying {
                                ProgressView()
                                    .padding(.trailing, 4)
                            }
                            Text(isVerifying ? "Verifying..." : "Verify Username")
                        }
                    }
                    .disabled(isVerifying)
                }
                
                Stepper("Daily Goal: \(dailyGoal) problems", value: $dailyGoal, in: 1...10)
            }
            
            Section(header: Text("Status")) {
                Toggle("Enable Requirement", isOn: $isEnabled)
                    .disabled(username.isEmpty)
                
                Toggle("Block Reward Redemption", isOn: $blocksRewards)
                    .disabled(!isEnabled)
                
                if blocksRewards {
                    Text("You must complete your daily LeetCode goal before redeeming rewards")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            if isEnabled {
                Section(header: Text("Today's Progress")) {
                    Button(action: refreshProgress) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Problems Solved")
                                    .foregroundColor(.primary)
                                if let lastUpdated = todayProgress?.lastUpdated {
                                    Text("Updated \(formatRelativeTime(lastUpdated)) ago")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            HStack(spacing: 4) {
                                Text("\(currentProgress)/\(dailyGoal)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(currentProgress >= dailyGoal ? .green : .primary)
                                
                                if currentProgress >= dailyGoal {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(isRefreshing)
                    
                    Button(action: refreshProgress) {
                        HStack {
                            if isRefreshing {
                                ProgressView()
                                    .padding(.trailing, 4)
                            }
                            Text(isRefreshing ? "Refreshing..." : "Refresh Progress")
                        }
                    }
                    .disabled(isRefreshing)
                }
            }
            
            Section(header: Text("How It Works")) {
                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(
                        icon: "1.circle.fill",
                        text: "Set your daily LeetCode goal"
                    )
                    FeatureRow(
                        icon: "2.circle.fill",
                        text: "Enable \"Block Reward Redemption\""
                    )
                    FeatureRow(
                        icon: "3.circle.fill",
                        text: "Complete your problems each day"
                    )
                    FeatureRow(
                        icon: "4.circle.fill",
                        text: "Only then can you redeem rewards"
                    )
                }
                .font(.caption)
            }
            
            Section(header: Text("Example")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Daily Goal: 3 problems")
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    Text("✓ Complete 3 LeetCode problems")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    Text("✓ Can now unlock screen time")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    Text("❌ Without completing goal: rewards locked")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("LeetCode Requirements")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadSettings)
        .onChange(of: username) { _, _ in saveSettings() }
        .onChange(of: dailyGoal) { _, _ in saveSettings() }
        .onChange(of: isEnabled) { _, _ in saveSettings() }
        .onChange(of: blocksRewards) { _, _ in saveSettings() }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
        .alert("Verification Result", isPresented: $showVerificationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(verificationMessage)
        }
    }
    
    private func loadSettings() {
        if let settings = appSettings {
            username = settings.leetcodeUsername
            dailyGoal = settings.leetcodeDailyGoal
            isEnabled = settings.leetcodeEnabled
            blocksRewards = settings.leetcodeBlocksRewards
        }
    }
    
    private func saveSettings() {
        if let settings = appSettings {
            settings.leetcodeUsername = username
            settings.leetcodeDailyGoal = dailyGoal
            settings.leetcodeEnabled = isEnabled && !username.isEmpty
            settings.leetcodeBlocksRewards = blocksRewards
            settings.updateTimestamp()
            try? modelContext.save()
        }
    }
    
    private func verifyUsername() {
        isVerifying = true
        
        Task {
            do {
                let isValid = try await LeetCodeService.verifyUsername(username)
                
                await MainActor.run {
                    isVerifying = false
                    if isValid {
                        verificationMessage = "✓ Username '\(username)' verified!\n\nYou can now enable the requirement."
                        showVerificationAlert = true
                    } else {
                        verificationMessage = "❌ Username '\(username)' not found.\n\nPlease check the spelling and try again."
                        showVerificationAlert = true
                        username = ""
                    }
                }
            } catch {
                await MainActor.run {
                    isVerifying = false
                    verificationMessage = "⚠️ Verification failed.\n\nPlease check your internet connection and try again."
                    showVerificationAlert = true
                }
            }
        }
    }
    
    private func refreshProgress() {
        isRefreshing = true
        
        Task {
            _ = await RequirementService.refreshLeetCodeProgress(modelContext: modelContext)
            
            await MainActor.run {
                isRefreshing = false
            }
        }
    }
    
    private func formatRelativeTime(_ date: Date) -> String {
        let interval = currentTime.timeIntervalSince(date)
        
        if interval < 0 {
            return "just now"
        } else if interval < 60 {
            return "\(Int(interval))s"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d"
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            Text(text)
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        LeetCodeRequirementsView()
            .modelContainer(DataStore.shared)
    }
}
