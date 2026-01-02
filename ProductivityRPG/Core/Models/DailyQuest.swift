import Foundation
import SwiftData

@Model
final class DailyQuest {
    var id: UUID
    var title: String
    var questDescription: String
    var targetCount: Int
    var currentProgress: Int
    var rewardMinutes: Int
    var rewardXP: Int
    var questType: QuestType
    var date: Date
    var isCompleted: Bool
    var isClaimed: Bool
    var sortOrder: Int
    
    init(
        id: UUID = UUID(),
        title: String,
        questDescription: String,
        targetCount: Int,
        currentProgress: Int = 0,
        rewardMinutes: Int,
        rewardXP: Int = 0,
        questType: QuestType,
        date: Date = Date(),
        isCompleted: Bool = false,
        isClaimed: Bool = false,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.title = title
        self.questDescription = questDescription
        self.targetCount = targetCount
        self.currentProgress = currentProgress
        self.rewardMinutes = rewardMinutes
        self.rewardXP = rewardXP
        self.questType = questType
        self.date = date
        self.isCompleted = isCompleted
        self.isClaimed = isClaimed
        self.sortOrder = sortOrder
    }
    
    var progressPercent: Double {
        guard targetCount > 0 else { return 0 }
        return min(Double(currentProgress) / Double(targetCount), 1.0)
    }
    
    var canClaim: Bool {
        return isCompleted && !isClaimed
    }
    
    static func normalizeToDay(_ date: Date) -> Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: date)
    }
}

enum QuestType: String, Codable {
    case dailyLogin = "Daily Login"
    case workHour = "Work Hour"
    case completeTasks = "Complete Tasks"
    case completeBlocks = "Complete Blocks"
    case earnMinutes = "Earn Minutes"
    case perfectBlock = "Perfect Block"
    case usePomodoro = "Use Pomodoro"
    case completeStreak = "Maintain Streak"
}
