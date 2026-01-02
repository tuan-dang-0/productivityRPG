import Foundation
import SwiftData

struct RecurringBlockService {
    static func generateBlocksForDate(_ date: Date, modelContext: ModelContext) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // Check if blocks already exist for this date
        let existingDescriptor = FetchDescriptor<TimeBlock>(
            predicate: #Predicate<TimeBlock> { block in
                block.startTime >= startOfDay && block.startTime < endOfDay && block.isRecurring == true
            }
        )
        
        let existingBlocks = (try? modelContext.fetch(existingDescriptor)) ?? []
        
        // Fetch all active recurring blocks
        let recurringDescriptor = FetchDescriptor<RecurringBlock>(
            predicate: #Predicate<RecurringBlock> { recurring in
                recurring.isActive == true
            }
        )
        
        guard let recurringBlocks = try? modelContext.fetch(recurringDescriptor) else { return }
        
        // Create time blocks for matching recurring patterns
        for recurring in recurringBlocks {
            guard recurring.shouldCreateBlockForDate(date) else { continue }
            
            // Check if this recurring block already has a block for this date
            let blockExists = existingBlocks.contains { block in
                block.title == recurring.title &&
                calendar.component(.hour, from: block.startTime) == recurring.startHour &&
                calendar.component(.minute, from: block.startTime) == recurring.startMinute
            }
            
            if !blockExists {
                let newBlock = recurring.createTimeBlock(for: date)
                modelContext.insert(newBlock)
                
                // Sync recurring block to calendar if calendar sync is enabled
                if UserDefaults.standard.bool(forKey: "calendarSyncEnabled") {
                    CalendarService.shared.syncBlock(newBlock, modelContext: modelContext)
                }
            }
        }
        
        try? modelContext.save()
    }
    
    static func generateBlocksForDateRange(from startDate: Date, to endDate: Date, modelContext: ModelContext) {
        let calendar = Calendar.current
        var currentDate = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        
        while currentDate <= end {
            generateBlocksForDate(currentDate, modelContext: modelContext)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
    }
    
    static func generateBlocksForNextWeek(modelContext: ModelContext) {
        let today = Date()
        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: today)!
        generateBlocksForDateRange(from: today, to: nextWeek, modelContext: modelContext)
    }
}
