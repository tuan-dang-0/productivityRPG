import Foundation
import SwiftData

struct WalletService {
    static func getOrCreateWallet(modelContext: ModelContext) -> RewardWallet? {
        let descriptor = FetchDescriptor<RewardWallet>()
        let wallets = (try? modelContext.fetch(descriptor)) ?? []
        
        if let wallet = wallets.first {
            resetDailyEarningsIfNeeded(wallet: wallet)
            return wallet
        }
        
        let newWallet = RewardWallet(availableMinutes: 0, earnedTodayMinutes: 0, lastEarnedDate: Date())
        modelContext.insert(newWallet)
        try? modelContext.save()
        return newWallet
    }
    
    static func addEarnedMinutes(_ minutes: Int, modelContext: ModelContext) {
        guard let wallet = getOrCreateWallet(modelContext: modelContext) else { return }
        
        // Apply screen time ratio
        let settingsDescriptor = FetchDescriptor<AppSettings>()
        let ratio = (try? modelContext.fetch(settingsDescriptor).first?.screenTimeRatio) ?? 1.0
        
        let adjustedMinutes = Int(Double(minutes) * ratio)
        
        wallet.availableMinutes += adjustedMinutes
        wallet.earnedTodayMinutes += adjustedMinutes
        wallet.lastEarnedDate = Date()
        
        try? modelContext.save()
    }
    
    static func redeemMinutes(_ minutes: Int, modelContext: ModelContext) async -> RedemptionAttempt {
        guard let wallet = getOrCreateWallet(modelContext: modelContext) else {
            return RedemptionAttempt(success: false, reason: "Wallet not found", progress: nil)
        }
        
        guard wallet.availableMinutes >= minutes else {
            return RedemptionAttempt(success: false, reason: "Insufficient minutes", progress: nil)
        }
        
        // Check daily requirements (LeetCode, Anki, etc.)
        let requirementCheck = await RequirementService.canRedeemRewards(modelContext: modelContext)
        
        if !requirementCheck.allowed {
            return RedemptionAttempt(
                success: false,
                reason: requirementCheck.reason ?? "Daily requirements not met",
                progress: requirementCheck.progress
            )
        }
        
        wallet.availableMinutes -= minutes
        wallet.redeemedMinutesRemaining = minutes
        wallet.redemptionStartTime = Date()
        try? modelContext.save()
        
        // Remove shields to allow access to blocked apps
        AppBlockingService.removeShields()
        
        return RedemptionAttempt(success: true, reason: nil, progress: requirementCheck.progress)
    }
    
    struct RedemptionAttempt {
        let success: Bool
        let reason: String?
        let progress: [String: String]?
    }
    
    static func updateRedeemedTime(modelContext: ModelContext) {
        guard let wallet = getOrCreateWallet(modelContext: modelContext) else { return }
        guard let startTime = wallet.redemptionStartTime, wallet.redeemedMinutesRemaining > 0 else { return }
        
        let elapsed = Date().timeIntervalSince(startTime)
        let totalSecondsRemaining = wallet.redeemedMinutesRemaining * 60
        let secondsElapsed = Int(elapsed)
        
        if secondsElapsed >= totalSecondsRemaining {
            wallet.redeemedMinutesRemaining = 0
            wallet.redemptionStartTime = nil
            try? modelContext.save()
            
            // Reapply shields when reward time expires
            AppBlockingService.reapplyShields(modelContext: modelContext)
        }
    }
    
    private static func resetDailyEarningsIfNeeded(wallet: RewardWallet) {
        if !DateUtils.isSameDay(wallet.lastEarnedDate, Date()) {
            wallet.earnedTodayMinutes = 0
        }
    }
}
