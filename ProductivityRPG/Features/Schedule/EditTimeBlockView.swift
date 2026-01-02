import SwiftUI
import SwiftData

struct EditTimeBlockView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \Subcategory.name, order: .forward) private var subcategories: [Subcategory]
    @Query private var settings: [AppSettings]
    @Query private var tutorialStates: [TutorialState]
    
    private var tutorialState: TutorialState? {
        tutorialStates.first
    }
    
    @State private var title: String
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var baseRewardMinutes: Int
    @State private var selectedSubcategory: Subcategory?
    @State private var isPomodoroMode: Bool
    @State private var isRecurring: Bool
    @State private var selectedDays: Set<Int>
    @State private var newTaskTitle = ""
    @State private var showTaskWarning = false
    
    var block: TimeBlock?
    var isNew: Bool { block == nil }
    
    @State private var workingTasks: [TaskItem] = []
    
    private var screenTimeRatio: Double {
        settings.first?.screenTimeRatio ?? 1.0
    }
    
    private var calculatedRewardMinutes: Int {
        let duration = endTime.timeIntervalSince(startTime)
        let hours = duration / 3600.0
        let baseMinutes = hours * 60.0
        return max(5, Int(baseMinutes * screenTimeRatio))
    }
    
    init(block: TimeBlock? = nil, defaultStart: Date? = nil, defaultEnd: Date? = nil) {
        self.block = block
        _title = State(initialValue: block?.title ?? "New Block")
        
        // Default to current time or later when creating new blocks
        let now = Date()
        let defaultStartTime = defaultStart ?? now
        let adjustedStartTime = defaultStartTime < now ? now : defaultStartTime
        let defaultEndTime = defaultEnd ?? adjustedStartTime.addingTimeInterval(1800)
        
        _startTime = State(initialValue: block?.startTime ?? adjustedStartTime)
        _endTime = State(initialValue: block?.endTime ?? defaultEndTime)
        
        // Calculate default reward based on duration and settings
        let duration = (block?.endTime ?? defaultEndTime).timeIntervalSince(block?.startTime ?? defaultStartTime)
        let hours = duration / 3600.0
        let baseMinutes = hours * 60.0
        // Note: We can't access @Query in init, so use default 1.0 ratio for new blocks
        let calculatedReward = max(5, Int(baseMinutes * 1.0))
        _baseRewardMinutes = State(initialValue: block?.baseRewardMinutes ?? calculatedReward)
        
        _selectedSubcategory = State(initialValue: block?.subcategory)
        _isPomodoroMode = State(initialValue: block?.isPomodoroMode ?? false)
        _isRecurring = State(initialValue: block?.isRecurring ?? false)
        _selectedDays = State(initialValue: [])
        
        // For new blocks, include default task
        if let existingBlock = block {
            _workingTasks = State(initialValue: existingBlock.tasks)
        } else {
            let defaultTask = TaskItem(title: "Complete Block")
            _workingTasks = State(initialValue: [defaultTask])
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Block Details")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                            .padding(.top, 16)
                        
                        VStack(spacing: 16) {
                            TextField("Title", text: $title, axis: .vertical)
                                .font(.body)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Category")
                                    .padding(.horizontal)
                                
                                if subcategories.isEmpty {
                                    Text("No categories available. Create one in Metrics.")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal)
                                } else {
                                    Picker("Subcategory", selection: $selectedSubcategory) {
                                        Text("None").tag(nil as Subcategory?)
                                        ForEach(subcategories) { subcategory in
                                            HStack {
                                                Text(subcategory.emoji)
                                                Text(subcategory.name)
                                            }
                                            .font(.body)
                                            .tag(subcategory as Subcategory?)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .frame(height: 120)
                                    .clipped()
                                }
                            }
                            
                            VStack(spacing: 16) {
                                DatePicker("Start Time", selection: $startTime, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                                DatePicker("End Time", selection: $endTime, in: startTime..., displayedComponents: [.date, .hourAndMinute])
                            }
                            .padding(.horizontal)
                            .onChange(of: startTime) { oldValue, newValue in
                                // Ensure end time is after start time and within same day
                                let calendar = Calendar.current
                                if !calendar.isDate(newValue, inSameDayAs: endTime) || endTime <= newValue {
                                    endTime = calendar.date(byAdding: .minute, value: 30, to: newValue) ?? newValue.addingTimeInterval(1800)
                                    
                                    // Cap end time to end of day if it crosses midnight
                                    if !calendar.isDate(newValue, inSameDayAs: endTime) {
                                        endTime = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: newValue)!).addingTimeInterval(-60)
                                    }
                                }
                            }
                            .onChange(of: endTime) { oldValue, newValue in
                                // Prevent blocks spanning multiple days
                                let calendar = Calendar.current
                                if !calendar.isDate(startTime, inSameDayAs: newValue) {
                                    endTime = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: startTime)!).addingTimeInterval(-60)
                                }
                            }
                            
                            Toggle("Recurring", isOn: $isRecurring)
                                .padding(.horizontal)
                            
                            if isRecurring {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Repeat On")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal)
                                    
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                                        ForEach(daysOfWeek, id: \.0) { day in
                                            DayToggleButton(
                                                day: day.1,
                                                isSelected: selectedDays.contains(day.0)
                                            ) {
                                                if selectedDays.contains(day.0) {
                                                    selectedDays.remove(day.0)
                                                } else {
                                                    selectedDays.insert(day.0)
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.bottom, 4)
                                }
                            }
                            
                            Toggle("Pomodoro Mode", isOn: $isPomodoroMode)
                                .padding(.horizontal)
                            
                            HStack {
                                Text("Reward: \(calculatedRewardMinutes) min")
                                Spacer()
                                Text("(auto-calculated)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                            .onChange(of: startTime) { _, _ in
                                baseRewardMinutes = calculatedRewardMinutes
                            }
                            .onChange(of: endTime) { _, _ in
                                baseRewardMinutes = calculatedRewardMinutes
                            }
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 20)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Tasks")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            ForEach(workingTasks) { task in
                                HStack {
                                    TextField("Task title", text: Binding(
                                        get: { task.title },
                                        set: { task.title = $0 }
                                    ), axis: .vertical)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                    
                                    Button(role: .destructive) {
                                        deleteTask(task)
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            HStack {
                                TextField("New task", text: $newTaskTitle, axis: .vertical)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                
                                Button("Add") {
                                    addTask()
                                }
                                .disabled(newTaskTitle.isEmpty)
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                }
            }
            .navigationTitle(isNew ? "New Block" : "Edit Block")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let tutorial = tutorialState, tutorial.isActive, tutorial.currentTutorialStep == .editAndSave {
                            tutorial.advanceStep()
                            try? modelContext.save()
                        }
                        saveBlock()
                    }
                    .disabled(title.isEmpty || workingTasks.isEmpty)
                }
            }
            .alert("Task Required", isPresented: $showTaskWarning) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("A task is required for rewards. Add at least one task to your block.")
            }
        }
        .overlay {
            if let tutorial = tutorialState, tutorial.isActive, tutorial.currentTutorialStep == .editAndSave {
                TutorialOverlay(
                    step: .editAndSave,
                    onSkip: {
                        tutorial.advanceStep()
                        try? modelContext.save()
                    }
                )
                .zIndex(999)
            }
        }
    }
    
    private func addTask() {
        guard !newTaskTitle.isEmpty else { return }
        
        let task = TaskItem(title: newTaskTitle, weight: 1.0, isCompleted: false)
        workingTasks.append(task)
        
        newTaskTitle = ""
    }
    
    private func deleteTask(_ task: TaskItem) {
        // Prevent deletion if it's the last task
        if workingTasks.count <= 1 {
            showTaskWarning = true
            return
        }
        
        if let index = workingTasks.firstIndex(where: { $0.id == task.id }) {
            workingTasks.remove(at: index)
        }
    }
    
    private let daysOfWeek = [
        (1, "Sun"),
        (2, "Mon"),
        (3, "Tue"),
        (4, "Wed"),
        (5, "Thu"),
        (6, "Fri"),
        (7, "Sat")
    ]
    
    private func saveBlock() {
        if isRecurring && !selectedDays.isEmpty {
            saveRecurringBlock()
        } else if let existingBlock = block {
            existingBlock.title = title
            existingBlock.startTime = startTime
            existingBlock.endTime = endTime
            existingBlock.baseRewardMinutes = baseRewardMinutes
            existingBlock.subcategory = selectedSubcategory
            existingBlock.isPomodoroMode = isPomodoroMode
            
            // Remove deleted tasks
            let currentTaskIds = Set(workingTasks.map { $0.id })
            existingBlock.tasks.forEach { task in
                if !currentTaskIds.contains(task.id) {
                    modelContext.delete(task)
                }
            }
            
            // Update or add tasks
            existingBlock.tasks = workingTasks
            workingTasks.forEach { task in
                task.parentBlock = existingBlock
                if task.modelContext == nil {
                    modelContext.insert(task)
                }
            }
            
            // Sync to calendar if enabled
            if UserDefaults.standard.bool(forKey: "calendarSyncEnabled") {
                Task {
                    var hasAccess = CalendarService.shared.hasCalendarAccess()
                    if !hasAccess {
                        hasAccess = await CalendarService.shared.requestCalendarAccess()
                    }
                    if hasAccess {
                        CalendarService.shared.syncBlock(existingBlock, modelContext: modelContext)
                    }
                }
            }
        } else {
            let newBlock = TimeBlock(
                title: title,
                startTime: startTime,
                endTime: endTime,
                baseRewardMinutes: baseRewardMinutes,
                isPomodoroMode: isPomodoroMode,
                isRecurring: false,
                subcategory: selectedSubcategory
            )
            modelContext.insert(newBlock)
            
            // Add tasks to new block
            newBlock.tasks = workingTasks
            workingTasks.forEach { task in
                task.parentBlock = newBlock
                modelContext.insert(task)
            }
            
            // Sync to calendar if enabled
            if UserDefaults.standard.bool(forKey: "calendarSyncEnabled") {
                Task {
                    var hasAccess = CalendarService.shared.hasCalendarAccess()
                    if !hasAccess {
                        hasAccess = await CalendarService.shared.requestCalendarAccess()
                    }
                    if hasAccess {
                        CalendarService.shared.syncBlock(newBlock, modelContext: modelContext)
                    }
                }
            }
        }
        
        try? modelContext.save()
        dismiss()
    }
    
    private func saveRecurringBlock() {
        let calendar = Calendar.current
        let startHour = calendar.component(.hour, from: startTime)
        let startMinute = calendar.component(.minute, from: startTime)
        let endHour = calendar.component(.hour, from: endTime)
        let endMinute = calendar.component(.minute, from: endTime)
        
        let recurringBlock = RecurringBlock(
            title: title,
            startHour: startHour,
            startMinute: startMinute,
            endHour: endHour,
            endMinute: endMinute,
            baseRewardMinutes: baseRewardMinutes,
            subcategory: selectedSubcategory,
            daysOfWeek: Array(selectedDays)
        )
        
        modelContext.insert(recurringBlock)
        
        // Generate blocks for the next week
        RecurringBlockService.generateBlocksForNextWeek(modelContext: modelContext)
        
        try? modelContext.save()
        dismiss()
    }
}

struct DayToggleButton: View {
    let day: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(day)
                .font(.caption)
                .fontWeight(isSelected ? .bold : .regular)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
    }
}
