import Foundation
import SwiftData

@Model
final class FocusSession {
    var id: UUID
    var date: Date
    var completionPercent: Double
    var minutesEarned: Int
    var blockTitleSnapshot: String
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        completionPercent: Double,
        minutesEarned: Int,
        blockTitleSnapshot: String
    ) {
        self.id = id
        self.date = date
        self.completionPercent = completionPercent
        self.minutesEarned = minutesEarned
        self.blockTitleSnapshot = blockTitleSnapshot
    }
}
