import Foundation
import SwiftData

enum StatType: String, Codable {
    case strength = "Strength"
    case agility = "Agility"
    case intelligence = "Intelligence"
    case artistry = "Artistry"
    
    var color: String {
        switch self {
        case .strength: return "#FF6B6B" // Lighter Red - dark mode friendly
        case .agility: return "#51CF66" // Lighter Green - dark mode friendly
        case .intelligence: return "#4DABF7" // Lighter Blue - dark mode friendly
        case .artistry: return "#CC5DE8" // Lighter Purple - dark mode friendly
        }
    }
}

@Model
final class Category {
    var id: UUID
    var statType: StatType
    var createdAt: Date
    
    @Relationship(deleteRule: .nullify, inverse: \Subcategory.category)
    var subcategories: [Subcategory]
    
    init(
        id: UUID = UUID(),
        statType: StatType,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.statType = statType
        self.createdAt = createdAt
        self.subcategories = []
    }
}
