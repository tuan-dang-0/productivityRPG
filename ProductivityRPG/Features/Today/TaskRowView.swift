import SwiftUI
import SwiftData

struct TaskRowView: View {
    @Bindable var task: TaskItem
    @Environment(\.modelContext) private var modelContext
    @State private var showTaskMenu = false
    @State private var showEditTask = false
    @State private var editedTitle = ""
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                task.isCompleted.toggle()
            }) {
                ZStack {
                    Circle()
                        .stroke(task.isCompleted ? Color.green : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.green)
                    }
                }
            }
            .buttonStyle(.plain)
            
            Text(task.title)
                .strikethrough(task.isCompleted)
                .foregroundColor(task.isCompleted ? .secondary : .primary)
            
            Spacer()
            
            Button(action: {
                showTaskMenu = true
            }) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.blue)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .confirmationDialog("Task Actions", isPresented: $showTaskMenu) {
            Button("Edit") {
                editedTitle = task.title
                showEditTask = true
            }
            Button("Delete", role: .destructive) {
                deleteTask()
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Edit Task", isPresented: $showEditTask) {
            TextField("Task title", text: $editedTitle)
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                task.title = editedTitle
                try? modelContext.save()
            }
        }
    }
    
    private func deleteTask() {
        modelContext.delete(task)
        try? modelContext.save()
    }
}
