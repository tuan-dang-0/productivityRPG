import Foundation
import SwiftData

struct SeedData {
    static func seedIfNeeded(modelContext: ModelContext) {
        let blockDescriptor = FetchDescriptor<TimeBlock>()
        let existingBlocks = (try? modelContext.fetch(blockDescriptor)) ?? []
        
        let categoryDescriptor = FetchDescriptor<Category>()
        let existingCategories = (try? modelContext.fetch(categoryDescriptor)) ?? []
        
        let profileDescriptor = FetchDescriptor<UserProfile>()
        let existingProfiles = (try? modelContext.fetch(profileDescriptor)) ?? []
        
        if existingCategories.isEmpty {
            seedCategories(modelContext: modelContext)
        }
        
        if existingProfiles.isEmpty {
            let profile = UserProfile()
            modelContext.insert(profile)
        }
        
        let walletDescriptor = FetchDescriptor<RewardWallet>()
        let existingWallets = (try? modelContext.fetch(walletDescriptor)) ?? []
        
        if existingWallets.isEmpty {
            let wallet = RewardWallet(availableMinutes: 0, earnedTodayMinutes: 0, lastEarnedDate: Date())
            modelContext.insert(wallet)
        }
        
        let spriteDescriptor = FetchDescriptor<UnlockableSprite>()
        let existingSprites = (try? modelContext.fetch(spriteDescriptor)) ?? []
        
        if existingSprites.isEmpty {
            seedUnlockableSprites(modelContext: modelContext)
        }
        
        let streakDescriptor = FetchDescriptor<StreakTracker>()
        let existingStreaks = (try? modelContext.fetch(streakDescriptor)) ?? []
        
        if existingStreaks.isEmpty {
            let streak = StreakTracker()
            modelContext.insert(streak)
        }
        
        let loginDescriptor = FetchDescriptor<DailyLogin>()
        let existingLogins = (try? modelContext.fetch(loginDescriptor)) ?? []
        
        if existingLogins.isEmpty {
            let login = DailyLogin()
            modelContext.insert(login)
        }
        
        let weekendBonusDescriptor = FetchDescriptor<WeekendBonus>()
        let existingBonuses = (try? modelContext.fetch(weekendBonusDescriptor)) ?? []
        
        if existingBonuses.isEmpty {
            let bonus = WeekendBonus()
            modelContext.insert(bonus)
        }
        
        let leetcodeDescriptor = FetchDescriptor<LeetCodeSettings>()
        let existingLeetCode = (try? modelContext.fetch(leetcodeDescriptor)) ?? []
        
        if existingLeetCode.isEmpty {
            let leetcode = LeetCodeSettings()
            modelContext.insert(leetcode)
        }
        
        let appSettingsDescriptor = FetchDescriptor<AppSettings>()
        let existingAppSettings = (try? modelContext.fetch(appSettingsDescriptor)) ?? []
        
        if existingAppSettings.isEmpty {
            let appSettings = AppSettings()
            modelContext.insert(appSettings)
        }
        
        let achievementDescriptor = FetchDescriptor<Achievement>()
        let existingAchievements = (try? modelContext.fetch(achievementDescriptor)) ?? []
        
        if existingAchievements.isEmpty {
            seedAchievements(modelContext: modelContext)
        }
        
        let tutorialDescriptor = FetchDescriptor<TutorialState>()
        let existingTutorials = (try? modelContext.fetch(tutorialDescriptor)) ?? []
        
        if existingTutorials.isEmpty {
            let tutorial = TutorialState()
            modelContext.insert(tutorial)
        }
        
        try? modelContext.save()
    }
    
    private static func seedCategories(modelContext: ModelContext) {
        // Create 4 stat categories
        let strength = Category(statType: .strength)
        let agility = Category(statType: .agility)
        let intelligence = Category(statType: .intelligence)
        let artistry = Category(statType: .artistry)
        
        modelContext.insert(strength)
        modelContext.insert(agility)
        modelContext.insert(intelligence)
        modelContext.insert(artistry)
        
        // Create default subcategories
        let subcategories = [
            Subcategory(name: "Gym", emoji: "💪", category: strength),
            Subcategory(name: "Guitar", emoji: "🎸", category: artistry),
            Subcategory(name: "Chess", emoji: "♟️", category: intelligence),
            Subcategory(name: "Reading", emoji: "📚", category: intelligence),
            Subcategory(name: "Cooking", emoji: "🍳", category: artistry)
        ]
        
        for subcategory in subcategories {
            modelContext.insert(subcategory)
        }
    }
    
    private static func seedUnlockableSprites(modelContext: ModelContext) {
        // Barbarian Character Sprites
        let barbarianSprites = [
            UnlockableSprite(
                name: "Novice Barbarian",
                spriteName: "barbarian",
                requiredLevel: 1,
                isUnlocked: true,
                unlockedDate: Date(),
                spriteDescription: "Your journey begins",
                spriteType: .character
            ),
            UnlockableSprite(
                name: "Trained Warrior",
                spriteName: "barbarian_10",
                requiredLevel: 10,
                spriteDescription: "Leather armor, honed skills",
                spriteType: .character
            ),
            UnlockableSprite(
                name: "Veteran Fighter",
                spriteName: "barbarian_20",
                requiredLevel: 20,
                spriteDescription: "Chainmail and battle scars",
                spriteType: .character
            ),
            UnlockableSprite(
                name: "Elite Warrior",
                spriteName: "barbarian_50",
                requiredLevel: 50,
                spriteDescription: "Master of combat",
                spriteType: .character
            ),
            UnlockableSprite(
                name: "Legendary Champion",
                spriteName: "barbarian_100",
                requiredLevel: 100,
                spriteDescription: "The ultimate warrior",
                spriteType: .character
            )
        ]
        
        // Mage Character Sprites
        let mageSprites = [
            UnlockableSprite(
                name: "Novice Mage",
                spriteName: "mage",
                requiredLevel: 1,
                isUnlocked: true,
                unlockedDate: Date(),
                spriteDescription: "Arcane studies begin",
                spriteType: .character
            ),
            UnlockableSprite(
                name: "Apprentice Mage",
                spriteName: "mage_10",
                requiredLevel: 10,
                spriteDescription: "First spells mastered",
                spriteType: .character
            ),
            UnlockableSprite(
                name: "Adept Sorcerer",
                spriteName: "mage_20",
                requiredLevel: 20,
                spriteDescription: "Channeling greater power",
                spriteType: .character
            ),
            UnlockableSprite(
                name: "Arch Mage",
                spriteName: "mage_50",
                requiredLevel: 50,
                spriteDescription: "Master of arcane arts",
                spriteType: .character
            ),
            UnlockableSprite(
                name: "Grand Magus",
                spriteName: "mage_100",
                requiredLevel: 100,
                spriteDescription: "Reality bends to your will",
                spriteType: .character
            )
        ]
        
        let characterSprites = barbarianSprites + mageSprites
        
        // Background Environments
        let backgroundSprites = [
            UnlockableSprite(
                name: "Village",
                spriteName: "start_background",
                requiredLevel: 1,
                isUnlocked: true,
                unlockedDate: Date(),
                spriteDescription: "Starter Hub - Safe zone where your journey begins",
                spriteType: .background
            ),
            UnlockableSprite(
                name: "Training Grounds",
                spriteName: "training_background",
                requiredLevel: 5,
                spriteDescription: "Farmlands & Training - Learn the basics",
                spriteType: .background
            ),
            UnlockableSprite(
                name: "Beastwood Forest",
                spriteName: "forest_background",
                requiredLevel: 10,
                spriteDescription: "Dense forest with beasts and dangers",
                spriteType: .background
            ),
            UnlockableSprite(
                name: "Bandit Pass",
                spriteName: "bandit_background",
                requiredLevel: 20,
                spriteDescription: "Roadlands controlled by bandits",
                spriteType: .background
            ),
            UnlockableSprite(
                name: "Ancient Ruins",
                spriteName: "dungeon_background",
                requiredLevel: 35,
                spriteDescription: "Catacombs filled with ancient secrets",
                spriteType: .background
            ),
            UnlockableSprite(
                name: "Kingdom Border",
                spriteName: "kingdom_background",
                requiredLevel: 50,
                spriteDescription: "Fortified town at the kingdom's edge",
                spriteType: .background
            )
        ]
        
        for sprite in characterSprites + backgroundSprites {
            modelContext.insert(sprite)
        }
    }
    
    private static func seedAchievements(modelContext: ModelContext) {
        // Login Days Achievements
        let loginDaysRequirements = [1, 5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 200, 300, 400, 500]
        let loginAchievements = loginDaysRequirements.map { days in
            Achievement(
                title: "\(days) Day\(days == 1 ? "" : "s") Logged",
                achievementDescription: "Log in for \(days) total day\(days == 1 ? "" : "s")",
                iconName: "calendar.badge.checkmark",
                category: .loginDays,
                requirement: days,
                rewards: [.minutes(30)]
            )
        }
        
        // Work Hours Achievements (XP rewards are small bonuses - most XP comes from time blocks)
        let workHoursData: [(hours: Int, xp: Int)] = [
            (5, 30),
            (10, 60),
            (20, 120),
            (50, 300),
            (100, 600),
            (200, 1200),
            (500, 3000),
            (1000, 6000)
        ]
        
        let workHoursAchievements = workHoursData.map { data in
            Achievement(
                title: "\(data.hours) Hour\(data.hours == 1 ? "" : "s") Worked",
                achievementDescription: "Complete \(data.hours) hour\(data.hours == 1 ? "" : "s") of focused work",
                iconName: "clock.badge.checkmark",
                category: .workHours,
                requirement: data.hours,
                rewards: [.minutes(60), .xp(data.xp)]
            )
        }
        
        for achievement in loginAchievements + workHoursAchievements {
            modelContext.insert(achievement)
        }
    }
}
