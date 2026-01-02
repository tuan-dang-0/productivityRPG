import Foundation
import SwiftData

@Model
final class UnlockableSprite {
    var id: UUID
    var name: String
    var spriteName: String
    var requiredLevel: Int
    var isUnlocked: Bool
    var unlockedDate: Date?
    var spriteDescription: String
    var spriteType: SpriteType
    
    init(
        id: UUID = UUID(),
        name: String,
        spriteName: String,
        requiredLevel: Int,
        isUnlocked: Bool = false,
        unlockedDate: Date? = nil,
        spriteDescription: String,
        spriteType: SpriteType
    ) {
        self.id = id
        self.name = name
        self.spriteName = spriteName
        self.requiredLevel = requiredLevel
        self.isUnlocked = isUnlocked
        self.unlockedDate = unlockedDate
        self.spriteDescription = spriteDescription
        self.spriteType = spriteType
    }
}

enum SpriteType: String, Codable {
    case character = "Character"
    case background = "Background"
}
