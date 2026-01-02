import SwiftUI
import SwiftData

struct TaskBacklogView: View {
    @Environment(\.modelContext) private var modelContext
    
    let selectedDate: Date
    let allBlocks: [TimeBlock]
    
    private var backlogTasks: [TaskItem] {
        let calendar = Calendar.current
        let selectedDay = calendar.startOfDay(for: selectedDate)
        
        // Get all completed blocks for the selected day
        let completedBlocks = allBlocks.filter { block in
            calendar.isDate(block.startTime, inSameDayAs: selectedDay) && block.hasBeenCompleted
        }
        
        // Collect all incomplete tasks from completed blocks
        var tasks: [TaskItem] = []
        for block in completedBlocks {
            tasks.append(contentsOf: block.tasks.filter { !$0.isCompleted })
        }
        
        return tasks
    }
    
    private var upcomingBlocks: [TimeBlock] {
        let calendar = Calendar.current
        let selectedDay = calendar.startOfDay(for: selectedDate)
        
        return allBlocks.filter { block in
            calendar.isDate(block.startTime, inSameDayAs: selectedDay) && !block.hasBeenCompleted
        }
    }
    
    var body: some View {
        if !backlogTasks.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Task Backlog")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                Text("Incomplete tasks from completed blocks")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ForEach(backlogTasks) { task in
                    BacklogTaskRow(task: task, upcomingBlocks: upcomingBlocks)
                }
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct BacklogTaskRow: View {
    @Bindable var task: TaskItem
    let upcomingBlocks: [TimeBlock]
    @Environment(\.modelContext) private var modelContext
    
    @State private var showMoveSheet = false
    
    var body: some View {
        HStack {
            Button(action: {
                task.isCompleted.toggle()
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .orange)
            }
            .buttonStyle(.plain)
            
            Text(task.title)
                .strikethrough(task.isCompleted)
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: {
                showMoveSheet = true
            }) {
                Image(systemName: "arrow.right.circle")
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showMoveSheet) {
            MoveTaskSheet(task: task, upcomingBlocks: upcomingBlocks)
        }
    }
}

struct MoveTaskSheet: View {
    let task: TaskItem
    let upcomingBlocks: [TimeBlock]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(upcomingBlocks) { block in
                    Button(action: {
                        moveTask(to: block)
                    }) {
                        HStack {
                            if let subcategory = block.subcategory {
                                Text(subcategory.emoji)
                                    .font(.title3)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(block.title)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(Formatters.formatTimeRange(start: block.startTime, end: block.endTime))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Move Task To")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func moveTask(to block: TimeBlock) {
        // Remove from old parent
        if let oldParent = task.parentBlock {
            if let index = oldParent.tasks.firstIndex(where: { $0.id == task.id }) {
                oldParent.tasks.remove(at: index)
            }
        }
        
        // Add to new parent
        task.parentBlock = block
        block.tasks.append(task)
        task.isCompleted = false // Reset completion status
        
        try? modelContext.save()
        dismiss()
    }
}
