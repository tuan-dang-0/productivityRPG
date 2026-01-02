import Foundation
import SwiftData

@Model
final class WeekendBonus {
    var id: UUID
    var lastClaimedDate: Date?
    var bonusMinutesEarned: Int
    var totalLifetimeBonusMinutes: Int
    
    init(
        id: UUID = UUID(),
        lastClaimedDate: Date? = nil,
        bonusMinutesEarned: Int = 0,
        totalLifetimeBonusMinutes: Int = 0
    ) {
        self.id = id
        self.lastClaimedDate = lastClaimedDate
        self.bonusMinutesEarned = bonusMinutesEarned
        self.totalLifetimeBonusMinutes = totalLifetimeBonusMinutes
    }
    
    func canClaimBonus() -> Bool {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        
        // Weekday: 1 = Sunday, 2 = Monday, ..., 6 = Friday, 7 = Saturday
        // Can claim Friday (6), Saturday (7), or Sunday (1)
        let isWeekend = weekday == 1 || weekday == 6 || weekday == 7
        
        guard isWeekend else { return false }
        
        // Check if already claimed this weekend
        guard let lastClaimed = lastClaimedDate else { return true }
        
        // Get start of current week (Monday)
        let startOfWeek = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        guard let weekStart = calendar.date(from: startOfWeek) else { return false }
        
        // Check if last claim was before this week's Friday
        let friday = calendar.date(byAdding: .day, value: 4, to: weekStart)!
        return lastClaimed < friday
    }
    
    func claimBonus(minutes: Int) {
        lastClaimedDate = Date()
        bonusMinutesEarned = minutes
        totalLifetimeBonusMinutes += minutes
    }
}
