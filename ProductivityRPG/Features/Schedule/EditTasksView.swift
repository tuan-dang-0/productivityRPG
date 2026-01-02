import SwiftUI
import SwiftData

struct EditTasksView: View {
    @Bindable var block: TimeBlock
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var newTaskTitle = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Tasks") {
                    ForEach(block.tasks) { task in
                        HStack {
                            TextField("Task title", text: Binding(
                                get: { task.title },
                                set: { task.title = $0 }
                            ))
                            
                            Spacer()
                            
                            Button(role: .destructive) {
                                deleteTask(task)
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                
                Section("Add New Task") {
                    HStack {
                        TextField("Task title", text: $newTaskTitle)
                        
                        Button("Add") {
                            addTask()
                        }
                        .disabled(newTaskTitle.isEmpty)
                    }
                }
            }
            .navigationTitle("Edit Tasks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        try? modelContext.save()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addTask() {
        guard !newTaskTitle.isEmpty else { return }
        
        let task = TaskItem(title: newTaskTitle, weight: 1.0, isCompleted: false)
        task.parentBlock = block
        block.tasks.append(task)
        modelContext.insert(task)
        
        newTaskTitle = ""
    }
    
    private func deleteTask(_ task: TaskItem) {
        if let index = block.tasks.firstIndex(where: { $0.id == task.id }) {
            block.tasks.remove(at: index)
        }
        modelContext.delete(task)
    }
}
