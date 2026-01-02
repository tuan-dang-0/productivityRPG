import Foundation
import SwiftData

struct UnlockService {
    static func checkAndUnlockSprites(profile: UserProfile, modelContext: ModelContext) {
        let currentLevel = profile.level
        let descriptor = FetchDescriptor<UnlockableSprite>(
            predicate: #Predicate<UnlockableSprite> { sprite in
                sprite.isUnlocked == false && sprite.requiredLevel <= currentLevel
            }
        )
        
        guard let spritesToUnlock = try? modelContext.fetch(descriptor) else { return }
        
        for sprite in spritesToUnlock {
            sprite.isUnlocked = true
            sprite.unlockedDate = Date()
        }
        
        try? modelContext.save()
    }
    
    static func getNewlyUnlockedSprites(oldLevel: Int, newLevel: Int, modelContext: ModelContext) -> [UnlockableSprite] {
        let descriptor = FetchDescriptor<UnlockableSprite>(
            predicate: #Predicate<UnlockableSprite> { sprite in
                sprite.requiredLevel > oldLevel && sprite.requiredLevel <= newLevel
            }
        )
        
        return (try? modelContext.fetch(descriptor)) ?? []
    }
}
