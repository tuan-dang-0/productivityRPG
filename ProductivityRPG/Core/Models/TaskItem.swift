import Foundation
import SwiftData

@Model
final class TaskItem {
    var id: UUID
    var title: String
    var weight: Double
    var isCompleted: Bool
    
    var parentBlock: TimeBlock?
    
    init(
        id: UUID = UUID(),
        title: String,
        weight: Double = 1.0,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.weight = weight
        self.isCompleted = isCompleted
    }
}
