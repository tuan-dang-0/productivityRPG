import SwiftUI
import SwiftData

struct CharacterCustomizationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var sprites: [UnlockableSprite]
    @Query private var profiles: [UserProfile]
    
    @State private var selectedTab = 0
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    private var unlockedCharacters: [UnlockableSprite] {
        sprites.filter { $0.spriteType == .character && $0.isUnlocked }
            .sorted { $0.requiredLevel < $1.requiredLevel }
    }
    
    private var lockedCharacters: [UnlockableSprite] {
        sprites.filter { $0.spriteType == .character && !$0.isUnlocked }
            .sorted { $0.requiredLevel < $1.requiredLevel }
    }
    
    private var charactersByClass: [String: [UnlockableSprite]] {
        let allCharacters = sprites.filter { $0.spriteType == .character }
        var grouped: [String: [UnlockableSprite]] = [:]
        
        for character in allCharacters {
            let className = getClassName(from: character.spriteName)
            if grouped[className] == nil {
                grouped[className] = []
            }
            grouped[className]?.append(character)
        }
        
        // Sort characters within each class by level
        for (key, value) in grouped {
            grouped[key] = value.sorted { $0.requiredLevel < $1.requiredLevel }
        }
        
        return grouped
    }
    
    private func getClassName(from spriteName: String) -> String {
        if spriteName.hasPrefix("barbarian") {
            return "Barbarian"
        } else if spriteName.hasPrefix("mage") {
            return "Mage"
        }
        return "Unknown"
    }
    
    private var unlockedBackgrounds: [UnlockableSprite] {
        sprites.filter { $0.spriteType == .background && $0.isUnlocked }
            .sorted { $0.requiredLevel < $1.requiredLevel }
    }
    
    private var lockedBackgrounds: [UnlockableSprite] {
        sprites.filter { $0.spriteType == .background && !$0.isUnlocked }
            .sorted { $0.requiredLevel < $1.requiredLevel }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                tabSelector
                
                TabView(selection: $selectedTab) {
                    CharacterGalleryByClassView(
                        charactersByClass: charactersByClass,
                        currentSelection: profile?.characterSprite ?? "barbarian"
                    ) { sprite in
                        selectCharacter(sprite)
                    }
                    .tag(0)
                    
                    BackgroundGalleryView(
                        unlocked: unlockedBackgrounds,
                        locked: lockedBackgrounds,
                        currentSelection: profile?.backgroundSprite ?? "start_background"
                    ) { sprite in
                        selectBackground(sprite)
                    }
                    .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Customize Character")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            CustomizationTabButton(title: "Characters", isSelected: selectedTab == 0) {
                withAnimation { selectedTab = 0 }
            }
            
            CustomizationTabButton(title: "Backgrounds", isSelected: selectedTab == 1) {
                withAnimation { selectedTab = 1 }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    private func selectCharacter(_ sprite: UnlockableSprite) {
        guard let profile = profile, sprite.isUnlocked else { return }
        profile.characterSprite = sprite.spriteName
        // Update character class based on sprite
        profile.characterClass = getClassName(from: sprite.spriteName)
        try? modelContext.save()
    }
    
    private func selectBackground(_ sprite: UnlockableSprite) {
        guard let profile = profile, sprite.isUnlocked else { return }
        profile.backgroundSprite = sprite.spriteName
        try? modelContext.save()
    }
}

struct CustomizationTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? .white : .secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSelected ? Color.appAccent : Color.clear)
                .cornerRadius(8)
        }
    }
}

struct CharacterGalleryByClassView: View {
    let charactersByClass: [String: [UnlockableSprite]]
    let currentSelection: String
    let onSelect: (UnlockableSprite) -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ForEach(charactersByClass.keys.sorted(), id: \.self) { className in
                    if let characters = charactersByClass[className] {
                        VStack(alignment: .leading, spacing: 12) {
                            classHeader(className: className, count: characters.count)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 16) {
                                ForEach(characters) { sprite in
                                    SpriteCard(
                                        sprite: sprite,
                                        isSelected: sprite.spriteName == currentSelection,
                                        isLocked: !sprite.isUnlocked,
                                        onTap: { onSelect(sprite) }
                                    )
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private func classHeader(className: String, count: Int) -> some View {
        HStack {
            Text(className)
                .font(.title2)
                .fontWeight(.bold)
            
            Text("(\(count))")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(.top, 8)
    }
}

struct BackgroundGalleryView: View {
    let unlocked: [UnlockableSprite]
    let locked: [UnlockableSprite]
    let currentSelection: String
    let onSelect: (UnlockableSprite) -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if !unlocked.isEmpty {
                    sectionHeader(title: "Unlocked", count: unlocked.count)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 16) {
                        ForEach(unlocked) { sprite in
                            BackgroundCard(
                                sprite: sprite,
                                isSelected: sprite.spriteName == currentSelection,
                                isLocked: false,
                                onTap: { onSelect(sprite) }
                            )
                        }
                    }
                }
                
                if !locked.isEmpty {
                    sectionHeader(title: "Locked", count: locked.count)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 16) {
                        ForEach(locked) { sprite in
                            BackgroundCard(
                                sprite: sprite,
                                isSelected: false,
                                isLocked: true,
                                onTap: {}
                            )
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private func sectionHeader(title: String, count: Int) -> some View {
        HStack {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
            
            Text("(\(count))")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

struct SpriteCard: View {
    let sprite: UnlockableSprite
    let isSelected: Bool
    let isLocked: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Image(sprite.spriteName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    if isLocked {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.7))
                            .frame(width: 80, height: 80)
                        
                        VStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            Text("Lvl \(sprite.requiredLevel)")
                                .font(.caption2)
                                .foregroundColor(.white)
                        }
                    }
                    
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.appAccent, lineWidth: 3)
                            .frame(width: 80, height: 80)
                    }
                }
                
                Text(sprite.name)
                    .font(.caption)
                    .foregroundColor(isLocked ? .secondary : .primary)
                    .lineLimit(1)
                
                Text("Lvl \(sprite.requiredLevel)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 100)
        }
        .disabled(isLocked)
    }
}

struct BackgroundCard: View {
    let sprite: UnlockableSprite
    let isSelected: Bool
    let isLocked: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Image(sprite.spriteName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 140, height: 90)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    if isLocked {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.7))
                            .frame(width: 140, height: 90)
                        
                        VStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            Text("Lvl \(sprite.requiredLevel)")
                                .font(.caption2)
                                .foregroundColor(.white)
                        }
                    }
                    
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.appAccent, lineWidth: 3)
                            .frame(width: 140, height: 90)
                    }
                }
                
                Text(sprite.name)
                    .font(.caption)
                    .foregroundColor(isLocked ? .secondary : .primary)
                    .lineLimit(1)
                
                Text("Lvl \(sprite.requiredLevel)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .disabled(isLocked)
    }
}
