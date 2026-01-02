import SwiftUI
import SwiftData

struct AddEditSubcategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let category: Category
    let subcategoryToEdit: Subcategory?
    
    @State private var name = ""
    @State private var selectedEmoji = "📝"
    
    private let emojiOptions = [
        "💻", "📚", "🏋️", "🎸", "🎨", "📝",
        "🧘", "🍳", "🎮", "⚽️", "🎯", "🔬",
        "✍️", "🎭", "📊", "🛠️", "🎵", "🏃"
    ]
    
    var isEditing: Bool {
        subcategoryToEdit != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("e.g., LeetCode, Gym, Deep Work", text: $name)
                }
                
                Section("Icon") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 12) {
                        ForEach(emojiOptions, id: \.self) { emoji in
                            Button(action: { selectedEmoji = emoji }) {
                                Text(emoji)
                                    .font(.largeTitle)
                                    .frame(width: 50, height: 50)
                                    .background(selectedEmoji == emoji ? Color.blue.opacity(0.2) : Color.clear)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Subcategory" : "New Subcategory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        saveSubcategory()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                if let existing = subcategoryToEdit {
                    name = existing.name
                    selectedEmoji = existing.emoji
                }
            }
        }
    }
    
    private func saveSubcategory() {
        if let existing = subcategoryToEdit {
            existing.name = name
            existing.emoji = selectedEmoji
        } else {
            let subcategory = Subcategory(
                name: name,
                emoji: selectedEmoji,
                category: category
            )
            modelContext.insert(subcategory)
        }
        
        try? modelContext.save()
        dismiss()
    }
}

struct SubcategoryTemplate {
    let name: String
    let emoji: String
    let statType: StatType
}

struct SubcategoryTemplatesView: View {
    let category: Category
    let onSelect: (SubcategoryTemplate) -> Void
    @Environment(\.dismiss) private var dismiss
    
    private var templates: [SubcategoryTemplate] {
        switch category.statType {
        case .strength:
            return [
                SubcategoryTemplate(name: "Gym Workout", emoji: "🏋️", statType: .strength),
                SubcategoryTemplate(name: "Running", emoji: "🏃", statType: .strength),
                SubcategoryTemplate(name: "Sports Practice", emoji: "⚽️", statType: .strength),
                SubcategoryTemplate(name: "Yoga", emoji: "🧘", statType: .strength)
            ]
        case .intelligence:
            return [
                SubcategoryTemplate(name: "LeetCode", emoji: "💻", statType: .intelligence),
                SubcategoryTemplate(name: "Deep Work", emoji: "📚", statType: .intelligence),
                SubcategoryTemplate(name: "Reading", emoji: "📖", statType: .intelligence),
                SubcategoryTemplate(name: "Research", emoji: "🔬", statType: .intelligence),
                SubcategoryTemplate(name: "Study Session", emoji: "✍️", statType: .intelligence)
            ]
        case .agility:
            return [
                SubcategoryTemplate(name: "Admin Tasks", emoji: "📊", statType: .agility),
                SubcategoryTemplate(name: "Email Processing", emoji: "📧", statType: .agility),
                SubcategoryTemplate(name: "Quick Errands", emoji: "🏃", statType: .agility),
                SubcategoryTemplate(name: "Organization", emoji: "🗂️", statType: .agility)
            ]
        case .artistry:
            return [
                SubcategoryTemplate(name: "Music Practice", emoji: "🎸", statType: .artistry),
                SubcategoryTemplate(name: "Drawing", emoji: "🎨", statType: .artistry),
                SubcategoryTemplate(name: "Writing", emoji: "✍️", statType: .artistry),
                SubcategoryTemplate(name: "Creative Project", emoji: "🎭", statType: .artistry),
                SubcategoryTemplate(name: "Cooking", emoji: "🍳", statType: .artistry)
            ]
        }
    }
    
    var body: some View {
        NavigationStack {
            List(templates, id: \.name) { template in
                Button(action: {
                    onSelect(template)
                }) {
                    HStack(spacing: 12) {
                        Text(template.emoji)
                            .font(.title2)
                        
                        Text(template.name)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
