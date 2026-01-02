import SwiftUI
import SwiftData
import Combine

struct RewardsView: View {
    @Query(sort: \FocusSession.date, order: .reverse) private var sessions: [FocusSession]
    @Query private var tutorialStates: [TutorialState]
    @Environment(\.modelContext) private var modelContext
    
    private var tutorialState: TutorialState? {
        tutorialStates.first
    }
    
    @State private var wallet: RewardWallet?
    @State private var showInsufficientFunds = false
    @State private var currentTime = Date()
    @State private var showRedeemPicker = false
    @State private var selectedMinutes = 5
    @State private var showBlockedApps = false
    @State private var showRequirementError = false
    @State private var requirementErrorMessage = ""
    @State private var requirementProgress: [String: String]?
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let wallet = wallet, wallet.redeemedMinutesRemaining > 0, let startTime = wallet.redemptionStartTime {
                        screenTimeTimerSection(wallet: wallet, startTime: startTime)
                    }
                    
                    WeekendBonusCard()
                    
                    walletSection
                    
                    blockedAppsSection
                    
                    recentSessionsSection
                }
                .padding()
                .padding(.bottom, 100)
            }
            .navigationTitle("Rewards")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showBlockedApps = true
                    }) {
                        Image(systemName: "lock.shield")
                    }
                }
            }
            .onAppear {
                loadWallet()
            }
            .onReceive(timer) { _ in
                currentTime = Date()
                WalletService.updateRedeemedTime(modelContext: modelContext)
                loadWallet()
            }
            .alert("Insufficient Minutes", isPresented: $showInsufficientFunds) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("You don't have enough minutes to redeem.")
            }
            .alert("Daily Requirements Not Met", isPresented: $showRequirementError) {
                Button("OK", role: .cancel) { }
            } message: {
                VStack(alignment: .leading, spacing: 8) {
                    Text(requirementErrorMessage)
                    if let progress = requirementProgress {
                        ForEach(Array(progress.keys.sorted()), id: \.self) { key in
                            Text("\(key): \(progress[key] ?? "")")
                        }
                    }
                }
            }
            .sheet(isPresented: $showRedeemPicker) {
                RedeemPickerView(
                    availableMinutes: wallet?.availableMinutes ?? 0,
                    selectedMinutes: $selectedMinutes,
                    onRedeem: redeemMinutes
                )
            }
            .sheet(isPresented: $showBlockedApps) {
                SimplifiedBlockedAppsView()
            }
            .overlay {
                if let tutorial = tutorialState, tutorial.isActive, tutorial.currentTutorialStep == .viewRewards {
                    TutorialOverlay(
                        step: .viewRewards,
                        onSkip: {
                            tutorial.advanceStep()
                            try? modelContext.save()
                        }
                    )
                    .zIndex(999)
                }
            }
        }
    }
    
    private func screenTimeTimerSection(wallet: RewardWallet, startTime: Date) -> some View {
        let elapsed = currentTime.timeIntervalSince(startTime)
        let totalSeconds = wallet.redeemedMinutesRemaining * 60
        let remainingSeconds = max(0, totalSeconds - Int(elapsed))
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        
        return VStack(spacing: 12) {
            HStack {
                Image(systemName: "clock.fill")
                    .font(.title3)
                    .foregroundColor(.green)
                
                Text("Screen Time Active")
                    .font(.headline)
                    .foregroundColor(.green)
            }
            
            Text(String(format: "%d:%02d", minutes, seconds))
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(.green)
            
            Text("Remaining")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green, lineWidth: 2)
        )
    }
    
    private var walletSection: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text("Available Minutes")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("\(wallet?.availableMinutes ?? 0)")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundColor(.appAccent)
                
                Text("Earned Today: \(wallet?.earnedTodayMinutes ?? 0) min")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            Button(action: { showRedeemPicker = true }) {
                Label("Redeem Minutes", systemImage: "gift.fill")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .disabled((wallet?.availableMinutes ?? 0) < 10)
        }
    }
    
    private var blockedAppsSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("App Blocking")
                        .font(.headline)
                    
                    Text("Manage apps that require reward minutes to access")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "lock.shield.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
            }
            
            Button(action: { showBlockedApps = true }) {
                Label("Manage Blocked Apps", systemImage: "gearshape")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var recentSessionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Sessions")
                .font(.title2)
                .bold()
            
            if sessions.isEmpty {
                ContentUnavailableView(
                    "No Sessions Yet",
                    systemImage: "clock.badge.checkmark",
                    description: Text("Complete focus sessions to see them here")
                )
            } else {
                ForEach(sessions.prefix(10)) { session in
                    sessionRow(session)
                }
            }
        }
    }
    
    private func sessionRow(_ session: FocusSession) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.blockTitleSnapshot)
                    .font(.headline)
                
                Text(Formatters.dateFormatter.string(from: session.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Formatters.formatPercent(session.completionPercent))")
                    .font(.subheadline)
                    .foregroundColor(.green)
                
                Text("+\(session.minutesEarned) min")
                    .font(.caption)
                    .foregroundColor(.appAccent)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func loadWallet() {
        wallet = WalletService.getOrCreateWallet(modelContext: modelContext)
    }
    
    private func redeemMinutes() {
        Task {
            let result = await WalletService.redeemMinutes(selectedMinutes, modelContext: modelContext)
            
            await MainActor.run {
                if result.success {
                    loadWallet()
                    showRedeemPicker = false
                } else if result.reason == "Insufficient minutes" {
                    showInsufficientFunds = true
                } else {
                    requirementErrorMessage = result.reason ?? "Unknown error"
                    requirementProgress = result.progress
                    showRequirementError = true
                }
            }
        }
    }
}

struct RedeemPickerView: View {
    let availableMinutes: Int
    @Binding var selectedMinutes: Int
    let onRedeem: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    private let minuteOptions = Array(stride(from: 5, through: 240, by: 1))
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Select Minutes to Redeem")
                    .font(.headline)
                    .padding(.top)
                
                Text("Available: \(availableMinutes) min")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("Minutes", selection: $selectedMinutes) {
                    ForEach(minuteOptions.filter { $0 <= availableMinutes }, id: \.self) { minutes in
                        Text("\(minutes) min").tag(minutes)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 200)
                
                Button(action: {
                    onRedeem()
                }) {
                    Text("Redeem \(selectedMinutes) Minutes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.appAccent)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .disabled(selectedMinutes > availableMinutes)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
