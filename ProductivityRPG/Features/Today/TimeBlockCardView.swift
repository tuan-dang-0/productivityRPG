import SwiftUI
import SwiftData

struct TimeBlockCardView: View {
    @Bindable var block: TimeBlock
    @Environment(\.modelContext) private var modelContext
    @Environment(FocusSessionService.self) private var sessionService
    @Query private var tutorialStates: [TutorialState]
    
    private var tutorialState: TutorialState? {
        tutorialStates.first
    }
    
    @State private var isExpanded = false
    @State private var showActiveSessionAlert = false
    @State private var newTaskTitle = ""
    @State private var showPomodoroOverlay = false
    @State private var showBlockMenu = false
    @State private var showEditBlock = false
    @State private var iconImage: UIImage?
    
    private var completionPercent: Double {
        RewardCalculator.calculateCompletion(tasks: block.tasks)
    }
    
    private var isActive: Bool {
        sessionService.isBlockActive(block.id)
    }
    
    private var allTasksCompleted: Bool {
        !block.tasks.isEmpty && block.tasks.allSatisfy { $0.isCompleted }
    }
    
    private var isPastEndTime: Bool {
        Date() > block.endTime
    }
    
    private var canEndWithoutConfirmation: Bool {
        allTasksCompleted || isPastEndTime
    }
    
    private var backgroundColor: Color {
        if isActive {
            return Color.green.opacity(0.2)
        }
        return Color.black
    }
    
    private var textColor: Color {
        if isActive {
            return backgroundColor.contrastingTextColor
        }
        return Color.white
    }
    
    private var statIconName: String? {
        guard let category = block.subcategory?.category else { return nil }
        switch category.statType {
        case .strength: return "strength_icon"
        case .agility: return "agility_icon"
        case .intelligence: return "intelligence_icon"
        case .artistry: return "artistry_icon"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if let image = iconImage {
                    Image(uiImage: image)
                        .resizable()
                        .interpolation(.medium)
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(block.title)
                        .font(.headline)
                        .foregroundColor(textColor)
                    
                    Text(Formatters.formatTimeRange(start: block.startTime, end: block.endTime))
                        .font(.subheadline)
                        .foregroundColor(textColor.opacity(0.7))
                }
                
                Spacer()
                
                Button(action: {
                    showBlockMenu = true
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.blue)
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(.plain)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    isExpanded.toggle()
                }
            }
            
            HStack {
                Text("Completion: \(Formatters.formatPercent(completionPercent))")
                    .font(.subheadline)
                    .foregroundColor(textColor.opacity(0.7))
                
                Spacer()
                
                if block.hasBeenCompleted {
                    Button("Completed") {
                        // Already completed, no action
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .disabled(true)
                } else if block.isPomodoroMode {
                    Button("Start Pomodoro") {
                        showPomodoroOverlay = true
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button("Quick Complete") {
                        quickCompleteBlock()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                }
            }
            
            if isExpanded {
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    if block.tasks.isEmpty {
                        Text("No tasks")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(block.tasks) { task in
                            TaskRowView(task: task)
                        }
                    }
                }
            }
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
        .confirmationDialog("Block Actions", isPresented: $showBlockMenu) {
            Button("Edit") {
                showEditBlock = true
            }
            Button("Delete", role: .destructive) {
                deleteBlock()
            }
            if block.isRecurring && block.recurringGroupId != nil {
                Button("Delete + Future Occurrences", role: .destructive) {
                    deleteRecurringBlocks()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .fullScreenCover(isPresented: $showPomodoroOverlay) {
            PomodoroOverlayView(block: block)
        }
        .sheet(isPresented: $showEditBlock) {
            EditTimeBlockView(block: block)
        }
        .onAppear {
            loadOptimizedIcon()
        }
        .onDisappear {
            iconImage = nil
        }
    }
    
    private func loadOptimizedIcon() {
        guard let iconName = statIconName,
              let original = UIImage(named: iconName) else { return }
        
        let targetSize = CGSize(width: 56, height: 56)
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0)
        original.draw(in: CGRect(origin: .zero, size: targetSize))
        iconImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    private func quickCompleteBlock() {
        // Auto-complete all tasks in Quick Complete mode
        for task in block.tasks {
            task.isCompleted = true
        }
        
        block.hasBeenCompleted = true
        
        let completion = RewardCalculator.calculateCompletion(tasks: block.tasks)
        let earnedMinutes = Int(Double(block.baseRewardMinutes) * completion)
        
        if earnedMinutes > 0 {
            WalletService.addEarnedMinutes(earnedMinutes, modelContext: modelContext)
        }
        
        // Update achievements and daily quests
        ProgressTracker.updateProgressOnBlockCompletion(block: block, modelContext: modelContext)
        
        // Update stats for RPG system (async for LeetCode validation)
        Task {
            await StatService.updateStatsForBlockCompletion(block: block, completion: completion, modelContext: modelContext)
        }
        
        // Advance tutorial if on completeBlock step and switch to Metrics tab
        if let tutorial = tutorialState, tutorial.currentTutorialStep == .completeBlock {
            tutorial.advanceStep()
            try? modelContext.save()
            
            // Post notification to switch to Metrics tab
            NotificationCenter.default.post(name: NSNotification.Name("SwitchToMetricsTab"), object: nil)
        }
        
        let session = FocusSession(
            date: Date(),
            completionPercent: completion,
            minutesEarned: earnedMinutes,
            blockTitleSnapshot: block.title
        )
        modelContext.insert(session)
        
        try? modelContext.save()
    }
    
    private func deleteBlock() {
        // Remove from calendar first
        CalendarService.shared.removeBlockFromCalendar(block)
        
        // Then delete from model
        modelContext.delete(block)
        try? modelContext.save()
    }
    
    private func deleteRecurringBlocks() {
        guard let groupId = block.recurringGroupId else { return }
        
        // Fetch all blocks and filter manually to avoid predicate issues with optionals
        let descriptor = FetchDescriptor<TimeBlock>()
        
        if let allBlocks = try? modelContext.fetch(descriptor) {
            let blocksToDelete = allBlocks.filter { b in
                b.recurringGroupId == groupId && b.startTime >= block.startTime
            }
            
            for blockToDelete in blocksToDelete {
                // Remove from calendar
                CalendarService.shared.removeBlockFromCalendar(blockToDelete)
                // Delete from model
                modelContext.delete(blockToDelete)
            }
        }
        
        try? modelContext.save()
    }
}
