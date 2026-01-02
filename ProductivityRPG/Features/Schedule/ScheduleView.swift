import SwiftUI
import SwiftData

struct ScheduleView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var allBlocks: [TimeBlock] = []
    
    @State private var showingAddBlock = false
    @State private var editingBlock: TimeBlock?
    @State private var selectedDate: Date = Date()
    @State private var dragOffset: CGFloat = 0
    @State private var weekOffset: Int = 0
    @State private var isDragging = false
    @State private var completionCache: [Date: Double] = [:]
    
    private func weekDays(offset: Int) -> [Date] {
        let calendar = Calendar.current
        let baseDate = calendar.date(byAdding: .weekOfYear, value: offset, to: selectedDate)!
        let selectedDay = calendar.startOfDay(for: baseDate)
        let weekday = calendar.component(.weekday, from: selectedDay)
        let daysFromMonday = (weekday == 1) ? 6 : weekday - 2
        let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: selectedDay)!
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }
    }
    
    private var selectedDayBlocks: [TimeBlock] {
        let calendar = Calendar.current
        let selectedDay = calendar.startOfDay(for: selectedDate)
        return allBlocks.filter { block in
            calendar.isDate(block.startTime, inSameDayAs: selectedDay)
        }
    }
    
    private func completionForDay(_ date: Date) -> Double {
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        
        // Return cached value if available
        if let cached = completionCache[normalizedDate] {
            return cached
        }
        
        return 0 // Return 0 if not cached yet
    }
    
    private func updateCompletionCache() {
        let calendar = Calendar.current
        var cache: [Date: Double] = [:]
        
        // Only calculate for visible weeks
        for offset in [-1, 0, 1] {
            for date in weekDays(offset: offset) {
                let normalizedDate = calendar.startOfDay(for: date)
                let dayBlocks = allBlocks.filter { calendar.isDate($0.startTime, inSameDayAs: normalizedDate) }
                
                if !dayBlocks.isEmpty {
                    let totalCompletion = dayBlocks.map { RewardCalculator.calculateCompletion(tasks: $0.tasks) }.reduce(0, +)
                    cache[normalizedDate] = totalCompletion / Double(dayBlocks.count)
                } else {
                    cache[normalizedDate] = 0
                }
            }
        }
        
        completionCache = cache
    }
    
    private func smartDefaultTime() -> (Date, Date) {
        let calendar = Calendar.current
        let minute = calendar.component(.minute, from: selectedDate)
        let hour = calendar.component(.hour, from: selectedDate)
        let roundedMinute = (minute / 30 + 1) * 30
        
        var components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        components.hour = hour + (roundedMinute / 60)
        components.minute = roundedMinute % 60
        components.second = 0
        
        let startTime = calendar.date(from: components)!
        let endTime = calendar.date(byAdding: .minute, value: 30, to: startTime)!
        return (startTime, endTime)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Text("Schedule")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if !Calendar.current.isDateInToday(selectedDate) {
                        Button(action: {
                            withAnimation {
                                selectedDate = Date()
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.uturn.left")
                                Text("Today")
                            }
                            .font(.caption)
                            .foregroundColor(.appAccent)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        ForEach([-1, 0, 1], id: \.self) { weekIndex in
                            HStack(spacing: 4) {
                                ForEach(weekDays(offset: weekIndex), id: \.self) { date in
                                    ScheduleWeekDayTab(date: date, isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate), completion: completionForDay(date)) {
                                        selectedDate = date
                                    }
                                }
                            }
                            .padding(.horizontal, 8)
                            .frame(width: geometry.size.width)
                        }
                    }
                    .offset(x: -geometry.size.width + dragOffset)
                    .gesture(
                        DragGesture(minimumDistance: 20)
                            .onChanged { value in
                                if !isDragging {
                                    isDragging = true
                                }
                                dragOffset = value.translation.width
                            }
                            .onEnded { value in
                                isDragging = false
                                let threshold: CGFloat = 80
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    if value.translation.width < -threshold {
                                        if let newDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: selectedDate) {
                                            selectedDate = newDate
                                        }
                                    } else if value.translation.width > threshold {
                                        if let newDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: selectedDate) {
                                            selectedDate = newDate
                                        }
                                    }
                                    dragOffset = 0
                                }
                            }
                    )
                    .simultaneousGesture(
                        TapGesture()
                            .onEnded { _ in
                                // Prevent tap interference
                            }
                    )
                }
                .frame(height: 84)
                
                HStack {
                    Button(action: {
                        withAnimation {
                            if let newDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: selectedDate) {
                                selectedDate = newDate
                            }
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.caption)
                            .foregroundColor(.appAccent)
                    }
                    
                    Spacer()
                    
                    Text(weekRangeText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            if let newDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: selectedDate) {
                                selectedDate = newDate
                            }
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.appAccent)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                Divider()
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if selectedDayBlocks.isEmpty {
                            ContentUnavailableView(
                                "No Blocks",
                                systemImage: "calendar.badge.clock",
                                description: Text("No blocks scheduled for this day")
                            )
                            .padding(.top, 40)
                        } else {
                            ForEach(selectedDayBlocks) { block in
                                ScheduleBlockRow(block: block, onEdit: {
                                    editingBlock = block
                                }, onDelete: {
                                    deleteBlock(block)
                                }, onDeleteFuture: block.isRecurring ? {
                                    deleteFutureBlocks(block)
                                } : nil)
                            }
                        }
                        
                        Button(action: {
                            showingAddBlock = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                Text("Add Block")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.appAccent)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    .padding(.bottom, 100)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if allBlocks.isEmpty {
                    selectedDate = Date()
                    RecurringBlockService.generateBlocksForNextWeek(modelContext: modelContext)
                    loadRecentBlocks()
                }
            }
            .sheet(isPresented: $showingAddBlock) {
                let (start, end) = smartDefaultTime()
                EditTimeBlockView(defaultStart: start, defaultEnd: end)
            }
            .sheet(item: $editingBlock) { block in
                EditTimeBlockView(block: block)
            }
        }
    }
    
    private var weekRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let currentWeek = weekDays(offset: 0)
        guard let first = currentWeek.first, let last = currentWeek.last else { return "" }
        return "\(formatter.string(from: first)) - \(formatter.string(from: last))"
    }
    
    private func deleteBlock(_ block: TimeBlock) {
        // Remove from calendar if exists
        if let eventId = block.calendarEventId {
            CalendarService.shared.deleteEvent(eventId: eventId)
        }
        
        modelContext.delete(block)
        try? modelContext.save()
        loadRecentBlocks()
    }
    
    private func deleteFutureBlocks(_ block: TimeBlock) {
        guard block.isRecurring else { return }
        
        let calendar = Calendar.current
        let blockDate = calendar.startOfDay(for: block.startTime)
        let blockTitle = block.title
        
        // Fetch all future blocks with same recurring pattern
        let descriptor = FetchDescriptor<TimeBlock>(
            predicate: #Predicate<TimeBlock> { futureBlock in
                futureBlock.isRecurring == true &&
                futureBlock.title == blockTitle &&
                futureBlock.startTime >= blockDate
            }
        )
        
        if let futureBlocks = try? modelContext.fetch(descriptor) {
            for futureBlock in futureBlocks {
                // Remove from calendar if exists
                if let eventId = futureBlock.calendarEventId {
                    CalendarService.shared.deleteEvent(eventId: eventId)
                }
                modelContext.delete(futureBlock)
            }
        }
        
        try? modelContext.save()
        loadRecentBlocks()
    }
    
    private func loadRecentBlocks() {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -14, to: Date())!
        let endDate = calendar.date(byAdding: .day, value: 21, to: Date())!
        
        let descriptor = FetchDescriptor<TimeBlock>(
            predicate: #Predicate<TimeBlock> { block in
                block.startTime >= startDate && block.startTime <= endDate
            },
            sortBy: [SortDescriptor(\.startTime, order: .forward)]
        )
        
        if let results = try? modelContext.fetch(descriptor) {
            allBlocks = results
            updateCompletionCache()
        }
    }
}

struct ScheduleWeekDayTab: View {
    let date: Date
    let isSelected: Bool
    let completion: Double
    let action: () -> Void
    
    private var dayLetter: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(dayLetter)
                    .font(.system(size: 10))
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : (isToday ? .appAccent : .secondary))
                
                Text(dayNumber)
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : (isToday ? .appAccent : .primary))
                
                Circle()
                    .fill(completion > 0 ? Color.green.opacity(0.3 + completion * 0.7) : Color.gray.opacity(0.2))
                    .frame(width: 5, height: 5)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(isSelected ? Color.appAccent : (isToday ? Color.appAccent.opacity(0.1) : Color.clear))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isToday && !isSelected ? Color.appAccent : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}
