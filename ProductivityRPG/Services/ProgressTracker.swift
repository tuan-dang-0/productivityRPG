import Foundation
import SwiftData

struct ProgressTracker {
    static func updateProgressOnBlockCompletion(block: TimeBlock, modelContext: ModelContext) {
        updateWorkHoursAchievements(block: block, modelContext: modelContext)
        updateDailyQuests(block: block, modelContext: modelContext)
    }
    
    private static func updateWorkHoursAchievements(block: TimeBlock, modelContext: ModelContext) {
        guard block.hasBeenCompleted else { return }
        
        // Calculate hours worked
        let duration = block.endTime.timeIntervalSince(block.startTime)
        let hours = duration / 3600.0
        
        // Fetch all work hours achievements
        let descriptor = FetchDescriptor<Achievement>()
        guard let allAchievements = try? modelContext.fetch(descriptor) else { return }
        
        let workHoursAchievements = allAchievements.filter { $0.category == .workHours }
        
        // Fetch all completed blocks to calculate total hours
        let blockDescriptor = FetchDescriptor<TimeBlock>(
            predicate: #Predicate<TimeBlock> { b in
                b.hasBeenCompleted == true
            }
        )
        
        guard let completedBlocks = try? modelContext.fetch(blockDescriptor) else { return }
        
        // Calculate total hours from all completed blocks
        var totalHours = 0.0
        for completedBlock in completedBlocks {
            let blockDuration = completedBlock.endTime.timeIntervalSince(completedBlock.startTime)
            totalHours += blockDuration / 3600.0
        }
        
        let totalHoursInt = Int(totalHours)
        
        // Update achievement progress
        for achievement in workHoursAchievements {
            achievement.currentProgress = totalHoursInt
            if totalHoursInt >= achievement.requirement && !achievement.isUnlocked {
                achievement.isUnlocked = true
                achievement.unlockedDate = Date()
            }
        }
        
        try? modelContext.save()
    }
    
    private static func updateDailyQuests(block: TimeBlock, modelContext: ModelContext) {
        guard block.hasBeenCompleted else { return }
        
        let today = DailyQuest.normalizeToDay(Date())
        
        // Fetch today's quests
        let descriptor = FetchDescriptor<DailyQuest>()
        guard let allQuests = try? modelContext.fetch(descriptor) else { return }
        
        let todayQuests = allQuests.filter { DailyQuest.normalizeToDay($0.date) == today }
        
        // Calculate hours worked for this block
        let duration = block.endTime.timeIntervalSince(block.startTime)
        let hours = duration / 3600.0
        
        for quest in todayQuests {
            switch quest.questType {
            case .workHour:
                // Recalculate total hours from all completed blocks today
                let blockDescriptor = FetchDescriptor<TimeBlock>(
                    predicate: #Predicate<TimeBlock> { b in
                        b.hasBeenCompleted == true
                    }
                )
                
                if let completedBlocks = try? modelContext.fetch(blockDescriptor) {
                    let calendar = Calendar.current
                    let todayNormalized = calendar.startOfDay(for: Date())
                    
                    // Filter blocks that ended today
                    let todayBlocks = completedBlocks.filter { block in
                        let blockEndDay = calendar.startOfDay(for: block.endTime)
                        return blockEndDay == todayNormalized
                    }
                    
                    // Calculate total hours as exact decimal
                    var totalHoursToday = 0.0
                    for completedBlock in todayBlocks {
                        let blockDuration = completedBlock.endTime.timeIntervalSince(completedBlock.startTime)
                        totalHoursToday += blockDuration / 3600.0
                    }
                    
                    // Store as integer hours (rounded down for display)
                    let hoursCompleted = Int(totalHoursToday)
                    quest.currentProgress = hoursCompleted
                    
                    // Check if quest is completed
                    if hoursCompleted >= quest.targetCount {
                        quest.isCompleted = true
                    }
                }
                
            case .completeTasks:
                // This quest type has been removed but keep the case for backwards compatibility
                break
                
            default:
                break
            }
        }
        
        try? modelContext.save()
    }
}
