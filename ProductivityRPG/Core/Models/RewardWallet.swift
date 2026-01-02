import Foundation
import SwiftData

@Model
final class RewardWallet {
    var id: UUID
    var availableMinutes: Int
    var earnedTodayMinutes: Int
    var lastEarnedDate: Date
    var redeemedMinutesRemaining: Int
    var redemptionStartTime: Date?
    
    init(
        id: UUID = UUID(),
        availableMinutes: Int = 0,
        earnedTodayMinutes: Int = 0,
        lastEarnedDate: Date = Date(),
        redeemedMinutesRemaining: Int = 0,
        redemptionStartTime: Date? = nil
    ) {
        self.id = id
        self.availableMinutes = availableMinutes
        self.earnedTodayMinutes = earnedTodayMinutes
        self.lastEarnedDate = lastEarnedDate
        self.redeemedMinutesRemaining = redeemedMinutesRemaining
        self.redemptionStartTime = redemptionStartTime
    }
}
