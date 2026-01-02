import SwiftUI
import SwiftData

struct NewMetricsView: View {
    @Query private var profiles: [UserProfile]
    @Query private var categories: [Category]
    @Query private var tutorialStates: [TutorialState]
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedStat: StatType = .strength
    @State private var statHistory: [StatHistory] = []
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    private var tutorialState: TutorialState? {
        tutorialStates.first
    }
    
    private var sortedCategories: [Category] {
        let order: [StatType] = [.strength, .agility, .intelligence, .artistry]
        return categories.sorted { cat1, cat2 in
            guard let index1 = order.firstIndex(of: cat1.statType),
                  let index2 = order.firstIndex(of: cat2.statType) else {
                return false
            }
            return index1 < index2
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    if let profile = profile {
                        CharacterView(profile: profile)
                        
                        StatGraphView(statHistory: statHistory, selectedStat: $selectedStat)
                        
                        CategoriesView(categories: categories)
                    }
                }
                .padding()
                .padding(.bottom, 100)
            }
            .navigationTitle("Metrics")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                // Load asynchronously to prevent UI blocking
                if statHistory.isEmpty {
                    await loadStatHistory()
                }
            }
            .overlay {
                if let tutorial = tutorialState, tutorial.isActive, tutorial.currentTutorialStep == .viewMetricsStats {
                    TutorialOverlay(
                        step: .viewMetricsStats,
                        onSkip: {
                            tutorial.advanceStep()
                            try? modelContext.save()
                        }
                    )
                    .zIndex(999)
                }
            }
        }
    }
    
    private func loadStatHistory() async {
        let descriptor = FetchDescriptor<StatHistory>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        await MainActor.run {
            if let results = try? modelContext.fetch(descriptor) {
                statHistory = Array(results.prefix(100))
            }
        }
    }
}

struct CharacterView: View {
    let profile: UserProfile
    @State private var showCustomization = false
    @Environment(\.modelContext) private var modelContext
    
    private var xpProgress: Double {
        let currentLevelXP = profile.experienceIntoCurrentLevel
        let xpNeededForNext = profile.experienceToNextLevel
        let totalForThisLevel = currentLevelXP + xpNeededForNext
        return totalForThisLevel > 0 ? Double(currentLevelXP) / Double(totalForThisLevel) : 0
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Pixel character with level below - tappable for customization
                Button(action: { showCustomization = true }) {
                    VStack(spacing: 8) {
                        ZStack {
                            Image(profile.backgroundSprite)
                                .resizable()
                                .interpolation(.medium)
                                .scaledToFill()
                                .frame(width: 120, height: 100)
                                .clipped()
                            
                            Image(profile.characterSprite)
                                .resizable()
                                .interpolation(.medium)
                                .scaledToFit()
                                .frame(width: 65, height: 65)
                            
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Image(systemName: "paintbrush.fill")
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                        .padding(4)
                                        .background(Color.appAccent.opacity(0.8))
                                        .clipShape(Circle())
                                        .padding(4)
                                }
                            }
                        }
                        .frame(width: 120, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appAccent.opacity(0.5), lineWidth: 2)
                        )
                        .drawingGroup()
                        
                        Text(profile.username.isEmpty ? "Lvl \(profile.level)" : profile.username)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
                
                // Stats grid
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        StatIconView(statType: .strength, value: profile.strengthStat)
                        StatIconView(statType: .agility, value: profile.agilityStat)
                    }
                    HStack(spacing: 12) {
                        StatIconView(statType: .intelligence, value: profile.intelligenceStat)
                        StatIconView(statType: .artistry, value: profile.artistryStat)
                    }
                }
            }
            
            // XP Bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("XP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(profile.totalXP) XP (Level \(profile.level))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.green)
                            .frame(width: geometry.size.width * xpProgress, height: 12)
                    }
                }
                .frame(height: 12)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .sheet(isPresented: $showCustomization) {
            CharacterCustomizationView()
        }
    }
}

struct StatIconView: View {
    let statType: StatType
    let value: Double
    
    private var iconName: String {
        switch statType {
        case .strength: return "strength_icon"
        case .agility: return "agility_icon"
        case .intelligence: return "intelligence_icon"
        case .artistry: return "artistry_icon"
        }
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Image(iconName)
                .resizable()
                .interpolation(.medium)
                .frame(width: 24, height: 24)
            
            Text(String(format: "%.1f", value))
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: statType.color))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.3))
        .cornerRadius(8)
    }
}

struct StatGraphView: View {
    let statHistory: [StatHistory]
    @Binding var selectedStat: StatType
    
    private var filteredHistory: [StatHistory] {
        statHistory
            .filter { $0.statType == selectedStat }
            .sorted { $0.date < $1.date }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Stat Progression")
                    .font(.headline)
                
                Spacer()
                
                Picker("Stat", selection: $selectedStat) {
                    ForEach([StatType.strength, .agility, .intelligence, .artistry], id: \.self) { stat in
                        Text(stat.rawValue).tag(stat)
                    }
                }
                .pickerStyle(.menu)
            }
            
            if filteredHistory.isEmpty {
                Text("No data yet. Complete blocks to see your progress!")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                LineGraphView(data: filteredHistory, statType: selectedStat)
                    .frame(height: 200)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct LineGraphView: View {
    let data: [StatHistory]
    let statType: StatType
    
    private var maxValue: Double {
        data.map { $0.value }.max() ?? 1
    }
    
    private var minValue: Double {
        data.map { $0.value }.min() ?? 0
    }
    
    var body: some View {
        GeometryReader { outerGeometry in
            HStack(spacing: 8) {
                // Y-axis labels
                VStack(alignment: .trailing, spacing: 0) {
                    ForEach(0..<5) { i in
                        let value = maxValue - (maxValue - minValue) * Double(i) / 4
                        Text(String(format: "%.1f", value))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(height: outerGeometry.size.height / 4, alignment: .top)
                    }
                }
                .frame(width: 35)
                
                // Graph
                GeometryReader { geometry in
                ZStack {
                    // Grid lines
                    ForEach(0..<5) { i in
                        Path { path in
                            let y = geometry.size.height * CGFloat(i) / 4
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                        }
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    }
                
                // Line graph
                if data.count > 1 {
                    Path { path in
                        for (index, point) in data.enumerated() {
                            let x = geometry.size.width * CGFloat(index) / CGFloat(data.count - 1)
                            let normalizedY = (point.value - minValue) / max(maxValue - minValue, 0.1)
                            let y = geometry.size.height * (1 - CGFloat(normalizedY))
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(Color(hex: statType.color), lineWidth: 3)
                }
                
                // Data points
                ForEach(Array(data.enumerated()), id: \.element.id) { index, point in
                    let x = geometry.size.width * CGFloat(index) / CGFloat(max(data.count - 1, 1))
                    let normalizedY = (point.value - minValue) / max(maxValue - minValue, 0.1)
                    let y = geometry.size.height * (1 - CGFloat(normalizedY))
                    
                    Circle()
                        .fill(Color(hex: statType.color))
                        .frame(width: 8, height: 8)
                        .position(x: x, y: y)
                }
            }
        }
            }
        }
    }
}

struct CategoriesView: View {
    let categories: [Category]
    @Environment(\.modelContext) private var modelContext
    
    private var sortedCategories: [Category] {
        let order: [StatType] = [.strength, .agility, .intelligence, .artistry]
        return categories.sorted { cat1, cat2 in
            guard let index1 = order.firstIndex(of: cat1.statType),
                  let index2 = order.firstIndex(of: cat2.statType) else {
                return false
            }
            return index1 < index2
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categories")
                .font(.headline)
            
            ForEach(sortedCategories) { category in
                CategorySection(category: category)
            }
        }
    }
}

struct CategorySection: View {
    @Bindable var category: Category
    @Environment(\.modelContext) private var modelContext
    @State private var isExpanded = true
    @State private var showingAddSubcategory = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(category.statType.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: category.statType.color))
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                if category.subcategories.isEmpty {
                    Text("No subcategories yet")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    ForEach(category.subcategories.sorted(by: { $0.name < $1.name })) { subcategory in
                        SubcategoryRow(subcategory: subcategory)
                    }
                }
                
                Button(action: {
                    showingAddSubcategory = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Subcategory")
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .sheet(isPresented: $showingAddSubcategory) {
            AddEditSubcategoryView(category: category, subcategoryToEdit: nil)
        }
    }
}

struct SubcategoryRow: View {
    @Bindable var subcategory: Subcategory
    @State private var completedBlockCount: Int = 0
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @Environment(\.modelContext) private var modelContext
    
    private var statColor: Color {
        guard let category = subcategory.category else { return .secondary }
        return Color(hex: category.statType.color)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Text(subcategory.emoji)
                .font(.title3)
            
            Text(subcategory.name)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("\(completedBlockCount)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(statColor)
            
            Menu {
                Button(action: { showingEditSheet = true }) {
                    Label("Edit", systemImage: "pencil")
                }
                Button(role: .destructive, action: { showingDeleteAlert = true }) {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.secondary)
                    .padding(4)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .onAppear {
            loadCompletedCount()
        }
        .sheet(isPresented: $showingEditSheet) {
            if let category = subcategory.category {
                AddEditSubcategoryView(category: category, subcategoryToEdit: subcategory)
            }
        }
        .alert("Delete Subcategory?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteSubcategory()
            }
        } message: {
            Text("This will remove the subcategory from all time blocks. This action cannot be undone.")
        }
    }
    
    private func loadCompletedCount() {
        let subcategoryId = subcategory.id
        let descriptor = FetchDescriptor<TimeBlock>(
            predicate: #Predicate<TimeBlock> { block in
                block.subcategory?.id == subcategoryId && block.hasBeenCompleted == true
            }
        )
        
        if let results = try? modelContext.fetch(descriptor) {
            completedBlockCount = results.count
        }
    }
    
    private func deleteSubcategory() {
        modelContext.delete(subcategory)
        try? modelContext.save()
    }
}
