import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var username: String
    var strengthStat: Double
    var agilityStat: Double
    var intelligenceStat: Double
    var artistryStat: Double
    var bonusExperience: Int
    var characterClass: String
    var characterSprite: String
    var backgroundSprite: String
    var createdAt: Date
    
    // MARK: - Leveling Constants
    // Stat gain: ~4 stat points per hour of work
    // Scaling adjusted so XP from achievements contributes meaningfully to leveling
    static let LEVEL_SCALING: Double = 16.67
    static let XP_PER_HOUR: Double = 4.0
    
    // MARK: - Computed Properties
    
    // Total of all stats (base XP)
    var totalStats: Double {
        return strengthStat + agilityStat + intelligenceStat + artistryStat
    }
    
    // Total XP (stats + bonus from achievements)
    var totalXP: Int {
        return Int(totalStats) + bonusExperience
    }
    
    // Current level calculated from total XP
    var level: Int {
        let xp = Double(totalXP)
        // Using quadratic formula: level = (-1 + sqrt(1 + 8*XP/0.289)) / 2
        let calculatedLevel = (-1.0 + sqrt(1.0 + 8.0 * xp / UserProfile.LEVEL_SCALING)) / 2.0
        return max(1, Int(floor(calculatedLevel)))
    }
    
    // Total XP required for current level
    private var xpForCurrentLevel: Int {
        // Sum formula: 0.289 * level * (level + 1) / 2
        return Int(UserProfile.LEVEL_SCALING * Double(level * (level + 1)) / 2.0)
    }
    
    // Total XP required for next level
    private var xpForNextLevel: Int {
        let nextLevel = level + 1
        return Int(UserProfile.LEVEL_SCALING * Double(nextLevel * (nextLevel + 1)) / 2.0)
    }
    
    // XP needed to reach next level
    var experienceToNextLevel: Int {
        return max(0, xpForNextLevel - totalXP)
    }
    
    // XP progress into current level
    var experienceIntoCurrentLevel: Int {
        return max(0, totalXP - xpForCurrentLevel)
    }
    
    init(
        id: UUID = UUID(),
        username: String = "",
        strengthStat: Double = 0,
        agilityStat: Double = 0,
        intelligenceStat: Double = 0,
        artistryStat: Double = 0,
        bonusExperience: Int = 0,
        characterClass: String = "Barbarian",
        characterSprite: String = "barbarian",
        backgroundSprite: String = "start_background",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.username = username
        self.strengthStat = strengthStat
        self.agilityStat = agilityStat
        self.intelligenceStat = intelligenceStat
        self.artistryStat = artistryStat
        self.bonusExperience = bonusExperience
        self.characterClass = characterClass
        self.characterSprite = characterSprite
        self.backgroundSprite = backgroundSprite
        self.createdAt = createdAt
    }
    
    // Add bonus XP (from achievements, etc.)
    func addBonusExperience(_ amount: Int, modelContext: ModelContext? = nil) {
        let oldLevel = level
        bonusExperience += amount
        
        // Auto-unlock sprites when leveling up
        if level > oldLevel, let context = modelContext {
            UnlockService.checkAndUnlockSprites(profile: self, modelContext: context)
        }
    }
    
    func increaseStat(_ statType: StatType, by amount: Double, modelContext: ModelContext? = nil) {
        let oldLevel = level
        
        switch statType {
        case .strength:
            strengthStat += amount
        case .agility:
            agilityStat += amount
        case .intelligence:
            intelligenceStat += amount
        case .artistry:
            artistryStat += amount
        }
        
        // Add bonus XP: for every stat point, add 6x more as bonus (total 7x)
        // Stats already count as 1x XP, so we add 6x more to reach 7x total
        let bonusAmount = Int(amount * 6.0)
        bonusExperience += bonusAmount
        
        // Auto-unlock sprites when leveling up
        if level > oldLevel, let context = modelContext {
            UnlockService.checkAndUnlockSprites(profile: self, modelContext: context)
        }
    }
    
    func decreaseStat(_ statType: StatType, by amount: Double, modelContext: ModelContext? = nil) {
        let oldLevel = level
        
        switch statType {
        case .strength:
            strengthStat = max(0, strengthStat - amount)
        case .agility:
            agilityStat = max(0, agilityStat - amount)
        case .intelligence:
            intelligenceStat = max(0, intelligenceStat - amount)
        case .artistry:
            artistryStat = max(0, artistryStat - amount)
        }
        
        // Level may decrease if stats drop below threshold
        // Note: This is intentional - skipping blocks can delevel you
    }
    
    func getStat(_ statType: StatType) -> Double {
        switch statType {
        case .strength: return strengthStat
        case .agility: return agilityStat
        case .intelligence: return intelligenceStat
        case .artistry: return artistryStat
        }
    }
}
