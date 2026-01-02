import SwiftUI
import SwiftData
import Combine

struct PomodoroOverlayView: View {
    @Bindable var block: TimeBlock
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var tutorialStates: [TutorialState]
    
    private var tutorialState: TutorialState? {
        tutorialStates.first
    }
    
    @State private var timeRemaining: TimeInterval = 60 * 60 // 1 hour in seconds
    @State private var isBreak = false
    @State private var pomodoroCount = 0
    @State private var isRunning = true
    @State private var blinkColor: Color? = nil
    @State private var blinkCount = 0
    @State private var showExitConfirmation = false
    
    private let pomodoroLength: TimeInterval = 60 * 60 // 60 minutes
    private let shortBreakLength: TimeInterval = 10 * 60 // 10 minutes
    private let longBreakLength: TimeInterval = 20 * 60 // 20 minutes
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var sessionType: String {
        if isBreak {
            return pomodoroCount % 4 == 0 ? "Long Break" : "Short Break"
        }
        return "Pomodoro"
    }
    
    private var progress: Double {
        let totalTime: TimeInterval
        if isBreak {
            totalTime = pomodoroCount % 4 == 0 ? longBreakLength : shortBreakLength
        } else {
            totalTime = pomodoroLength
        }
        return 1.0 - (timeRemaining / totalTime)
    }
    
    private var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private var nextTask: TaskItem? {
        block.tasks.first { !$0.isCompleted }
    }
    
    private var completedTaskCount: Int {
        block.tasks.filter { $0.isCompleted }.count
    }
    
    private var totalTaskCount: Int {
        block.tasks.count
    }
    
    private var taskProgress: Double {
        guard totalTaskCount > 0 else { return 0 }
        return Double(completedTaskCount) / Double(totalTaskCount)
    }
    
    var body: some View {
        ZStack {
            (blinkColor ?? Color.black).ignoresSafeArea()
            
            VStack(spacing: 40) {
                Text(sessionType)
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 20)
                        .frame(width: 280, height: 280)
                    
                    // Progress circle
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            isBreak ? Color.green : Color.blue,
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .frame(width: 280, height: 280)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: progress)
                    
                    // Time text
                    Text(formattedTime)
                        .font(.system(size: 60, weight: .light, design: .rounded))
                        .foregroundColor(.white)
                }
                
                HStack(spacing: 30) {
                    Button(action: {
                        isRunning.toggle()
                    }) {
                        Image(systemName: isRunning ? "pause.fill" : "play.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.gray.opacity(0.3))
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        skipSession()
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.gray.opacity(0.3))
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        checkBeforeExit()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.red.opacity(0.6))
                            .clipShape(Circle())
                    }
                }
                
                VStack(spacing: 16) {
                    Text(block.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    if let task = nextTask {
                        Button(action: {
                            task.isCompleted.toggle()
                        }) {
                            HStack {
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(task.isCompleted ? .green : .white)
                                Text(task.title)
                                    .foregroundColor(.white)
                                    .strikethrough(task.isCompleted)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(12)
                        }
                    }
                    
                    VStack(spacing: 8) {
                        Text("Tasks completed: \(completedTaskCount)/\(totalTaskCount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 8)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.green)
                                    .frame(width: geometry.size.width * taskProgress, height: 8)
                            }
                        }
                        .frame(height: 8)
                    }
                    .padding(.horizontal, 40)
                }
            }
        }
        .onReceive(timer) { _ in
            if isRunning && timeRemaining > 0 {
                timeRemaining -= 1
            } else if timeRemaining <= 0 {
                sessionCompleted()
            }
        }
        .onAppear {
            startPomodoro()
        }
        .alert("Are you sure?", isPresented: $showExitConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Exit", role: .destructive) {
                endPomodoro()
            }
        } message: {
            Text("You have incomplete tasks or the time block hasn't ended yet. Are you sure you want to exit?")
        }
    }
    
    private func startPomodoro() {
        isBreak = false
        timeRemaining = pomodoroLength
        isRunning = true
    }
    
    private func startBreak() {
        isBreak = true
        if pomodoroCount % 4 == 0 {
            timeRemaining = longBreakLength
        } else {
            timeRemaining = shortBreakLength
        }
        isRunning = true
    }
    
    private func sessionCompleted() {
        if isBreak {
            // Break -> Pomodoro: Blink red
            blinkScreen(color: .red) {
                startPomodoro()
            }
        } else {
            // Pomodoro -> Break: Blink green
            pomodoroCount += 1
            blinkScreen(color: .green) {
                startBreak()
            }
        }
    }
    
    private func blinkScreen(color: Color, completion: @escaping () -> Void) {
        blinkCount = 0
        blinkColor = color
        
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
            blinkCount += 1
            blinkColor = (blinkCount % 2 == 0) ? color : .black
            
            if blinkCount >= 6 { // 3 blinks (on-off-on-off-on-off)
                timer.invalidate()
                blinkColor = nil
                completion()
            }
        }
    }
    
    private func skipSession() {
        if isBreak {
            startPomodoro()
        } else {
            pomodoroCount += 1
            startBreak()
        }
    }
    
    private func checkBeforeExit() {
        let hasIncompleteTasks = block.tasks.contains { !$0.isCompleted }
        let currentTime = Date()
        let blockNotEnded = currentTime < block.endTime
        
        if hasIncompleteTasks || blockNotEnded {
            showExitConfirmation = true
        } else {
            endPomodoro()
        }
    }
    
    private func endPomodoro() {
        // Mark block as completed
        block.hasBeenCompleted = true
        
        // Calculate rewards based on completion
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
        
        // Create focus session
        let session = FocusSession(
            date: Date(),
            completionPercent: completion,
            minutesEarned: earnedMinutes,
            blockTitleSnapshot: block.title
        )
        modelContext.insert(session)
        
        try? modelContext.save()
        dismiss()
    }
}
