import Foundation
import SwiftData

@Model
final class AppSettings {
    var id: UUID
    
    // Calendar & Scheduling
    var calendarSyncEnabled: Bool
    
    // App Blocking / Screen Time
    var appBlockingEnabled: Bool
    var screenTimeRatio: Double  // Hours of screen time per hour of work
    
    // LeetCode Daily Requirements
    var leetcodeEnabled: Bool
    var leetcodeUsername: String
    var leetcodeDailyGoal: Int
    var leetcodeBlocksRewards: Bool  // If true, must meet goal to redeem rewards
    var leetcodeLastChecked: Date?
    
    // Anki Daily Requirements (Future)
    var ankiEnabled: Bool
    var ankiDailyGoal: Int
    var ankiBlocksRewards: Bool
    
    // Appearance
    var accentColorHex: String  // Hex color string for app accent color
    
    // General
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        calendarSyncEnabled: Bool = false,
        appBlockingEnabled: Bool = false,
        screenTimeRatio: Double = 0.5,
        leetcodeEnabled: Bool = false,
        leetcodeUsername: String = "",
        leetcodeDailyGoal: Int = 3,
        leetcodeBlocksRewards: Bool = false,
        leetcodeLastChecked: Date? = nil,
        ankiEnabled: Bool = false,
        ankiDailyGoal: Int = 50,
        ankiBlocksRewards: Bool = false,
        accentColorHex: String = "007AFF",  // Default iOS blue
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.calendarSyncEnabled = calendarSyncEnabled
        self.appBlockingEnabled = appBlockingEnabled
        self.screenTimeRatio = screenTimeRatio
        self.leetcodeEnabled = leetcodeEnabled
        self.leetcodeUsername = leetcodeUsername
        self.leetcodeDailyGoal = leetcodeDailyGoal
        self.leetcodeBlocksRewards = leetcodeBlocksRewards
        self.leetcodeLastChecked = leetcodeLastChecked
        self.ankiEnabled = ankiEnabled
        self.ankiDailyGoal = ankiDailyGoal
        self.ankiBlocksRewards = ankiBlocksRewards
        self.accentColorHex = accentColorHex
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    func updateTimestamp() {
        updatedAt = Date()
    }
}
