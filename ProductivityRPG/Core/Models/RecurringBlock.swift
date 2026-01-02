import Foundation
import SwiftData

@Model
final class RecurringBlock {
    var id: UUID
    var title: String
    var startHour: Int
    var startMinute: Int
    var endHour: Int
    var endMinute: Int
    var baseRewardMinutes: Int
    var subcategory: Subcategory?
    var isActive: Bool
    var daysOfWeek: [Int]
    var createdDate: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        startHour: Int,
        startMinute: Int,
        endHour: Int,
        endMinute: Int,
        baseRewardMinutes: Int,
        subcategory: Subcategory?,
        isActive: Bool = true,
        daysOfWeek: [Int] = [],
        createdDate: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.startHour = startHour
        self.startMinute = startMinute
        self.endHour = endHour
        self.endMinute = endMinute
        self.baseRewardMinutes = baseRewardMinutes
        self.subcategory = subcategory
        self.isActive = isActive
        self.daysOfWeek = daysOfWeek
        self.createdDate = createdDate
    }
    
    var durationInMinutes: Int {
        let startMinutes = startHour * 60 + startMinute
        let endMinutes = endHour * 60 + endMinute
        return endMinutes - startMinutes
    }
    
    func shouldCreateBlockForDate(_ date: Date) -> Bool {
        guard isActive else { return false }
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        return daysOfWeek.contains(weekday)
    }
    
    func createTimeBlock(for date: Date) -> TimeBlock {
        let calendar = Calendar.current
        let startTime = calendar.date(bySettingHour: startHour, minute: startMinute, second: 0, of: date)!
        let endTime = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: date)!
        
        return TimeBlock(
            title: title,
            startTime: startTime,
            endTime: endTime,
            baseRewardMinutes: baseRewardMinutes,
            isRecurring: true,
            subcategory: subcategory
        )
    }
}
