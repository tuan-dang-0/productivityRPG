import Foundation
import SwiftData

@Model
final class TimeBlock {
    var id: UUID
    var title: String
    var startTime: Date
    var endTime: Date
    var baseRewardMinutes: Int
    var createdAt: Date
    var hasBeenCompleted: Bool
    var isPomodoroMode: Bool
    var isRecurring: Bool
    var recurringGroupId: String?
    var calendarEventId: String?
    
    var subcategory: Subcategory?
    
    @Relationship(deleteRule: .cascade, inverse: \TaskItem.parentBlock)
    var tasks: [TaskItem]
    
    init(
        id: UUID = UUID(),
        title: String,
        startTime: Date,
        endTime: Date,
        baseRewardMinutes: Int = 20,
        createdAt: Date = Date(),
        hasBeenCompleted: Bool = false,
        isPomodoroMode: Bool = false,
        isRecurring: Bool = false,
        recurringGroupId: String? = nil,
        calendarEventId: String? = nil,
        subcategory: Subcategory? = nil
    ) {
        self.id = id
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.baseRewardMinutes = baseRewardMinutes
        self.createdAt = createdAt
        self.hasBeenCompleted = hasBeenCompleted
        self.isPomodoroMode = isPomodoroMode
        self.isRecurring = isRecurring
        self.recurringGroupId = recurringGroupId
        self.calendarEventId = calendarEventId
        self.subcategory = subcategory
        self.tasks = []
        
        // Add default task
        let defaultTask = TaskItem(title: "Complete Block")
        self.tasks = [defaultTask]
    }
}
