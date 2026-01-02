import Foundation
import SwiftData

@Model
final class StatHistory {
    var id: UUID
    var date: Date
    var statType: StatType
    var value: Double
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        statType: StatType,
        value: Double
    ) {
        self.id = id
        self.date = date
        self.statType = statType
        self.value = value
    }
}
