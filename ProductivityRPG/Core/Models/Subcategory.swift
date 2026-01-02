import Foundation
import SwiftData

@Model
final class Subcategory {
    var id: UUID
    var name: String
    var emoji: String
    var createdAt: Date
    
    var category: Category?
    
    @Relationship(deleteRule: .nullify, inverse: \TimeBlock.subcategory)
    var blocks: [TimeBlock]
    
    // Computed property: color comes from parent category's stat type
    var colorHex: String {
        category?.statType.color ?? "#808080" // Default gray if no category
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        emoji: String,
        category: Category? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.category = category
        self.createdAt = createdAt
        self.blocks = []
    }
}
