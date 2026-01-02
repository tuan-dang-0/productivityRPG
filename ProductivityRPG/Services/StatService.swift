import Foundation
import SwiftData

struct StatService {
    static func updateStatsForBlockCompletion(block: TimeBlock, completion: Double, modelContext: ModelContext) async {
        guard let subcategory = block.subcategory,
              let category = subcategory.category else {
            return
        }
        
        // Get or create user profile
        let profileDescriptor = FetchDescriptor<UserProfile>()
        guard let profile = (try? modelContext.fetch(profileDescriptor))?.first else {
            return
        }
        
        // Calculate base stat increase (stats = XP in the system)
        let duration = block.endTime.timeIntervalSince(block.startTime)
        let hours = duration / 3600.0
        let baseIncrease = hours * UserProfile.XP_PER_HOUR // 28.8 XP per hour
        let actualIncrease = baseIncrease * completion
        
        // Check for LeetCode validation (if Intelligence category and LeetCode enabled)
        var validationMultiplier = 1.0
        var validationDetails: String? = nil
        
        if category.statType == .intelligence {
            let settingsDescriptor = FetchDescriptor<LeetCodeSettings>()
            if let leetcodeSettings = try? modelContext.fetch(settingsDescriptor).first,
               leetcodeSettings.isConfigured() {
                
                let result = await LeetCodeService.validateBlockActivity(
                    username: leetcodeSettings.username,
                    startTime: block.startTime,
                    endTime: block.endTime
                )
                
                if result.verified {
                    validationMultiplier = result.multiplier
                    validationDetails = result.details
                    leetcodeSettings.lastValidated = Date()
                }
            }
        }
        
        // Apply validation multiplier
        let finalIncrease = actualIncrease * validationMultiplier
        
        // Increase the stat (pass modelContext for auto-unlocking)
        profile.increaseStat(category.statType, by: finalIncrease, modelContext: modelContext)
        
        // Record stat history for graphing
        let history = StatHistory(
            date: Date(),
            statType: category.statType,
            value: profile.getStat(category.statType)
        )
        modelContext.insert(history)
        
        // Show notification if validation bonus applied
        if let details = validationDetails, validationMultiplier > 1.0 {
            let bonusPercent = Int((validationMultiplier - 1.0) * 100)
            NotificationService.sendLeetCodeValidation(
                bonusPercent: bonusPercent,
                details: details
            )
        }
        
        try? modelContext.save()
    }
    
    static func decreaseStatsForBlockSkip(block: TimeBlock, modelContext: ModelContext) {
        guard let subcategory = block.subcategory,
              let category = subcategory.category else {
            return
        }
        
        // Get or create user profile
        let profileDescriptor = FetchDescriptor<UserProfile>()
        guard let profile = (try? modelContext.fetch(profileDescriptor))?.first else {
            return
        }
        
        // Calculate stat decrease (50% of what would have been gained)
        let duration = block.endTime.timeIntervalSince(block.startTime)
        let hours = duration / 3600.0
        let baseIncrease = hours * UserProfile.XP_PER_HOUR  // 28.8 XP per hour
        let decrease = baseIncrease * 0.5  // 50% penalty for skipping
        
        // Decrease the stat (may cause level decrease)
        profile.decreaseStat(category.statType, by: decrease, modelContext: modelContext)
        
        // Record stat history for graphing
        let history = StatHistory(
            date: Date(),
            statType: category.statType,
            value: profile.getStat(category.statType)
        )
        modelContext.insert(history)
        
        try? modelContext.save()
    }
}
