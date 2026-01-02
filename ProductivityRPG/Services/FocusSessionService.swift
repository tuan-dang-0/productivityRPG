import Foundation
import SwiftData

@Observable
class FocusSessionService {
    var activeBlockId: UUID?
    var sessionStartTime: Date?
    
    func startSession(blockId: UUID) {
        self.activeBlockId = blockId
        self.sessionStartTime = Date()
    }
    
    func endSession(
        block: TimeBlock,
        modelContext: ModelContext
    ) {
        guard activeBlockId == block.id else { return }
        
        let completionPercent = RewardCalculator.calculateCompletion(tasks: block.tasks)
        let minutesEarned = RewardCalculator.calculateEarnedMinutes(
            baseRewardMinutes: block.baseRewardMinutes,
            completionPercent: completionPercent
        )
        
        let session = FocusSession(
            date: Date(),
            completionPercent: completionPercent,
            minutesEarned: minutesEarned,
            blockTitleSnapshot: block.title
        )
        modelContext.insert(session)
        
        WalletService.addEarnedMinutes(minutesEarned, modelContext: modelContext)
        
        block.hasBeenCompleted = true
        
        // Update achievements and daily quests
        ProgressTracker.updateProgressOnBlockCompletion(block: block, modelContext: modelContext)
        
        // Advance tutorial if on completeBlock step and switch to Metrics tab
        let tutorialDescriptor = FetchDescriptor<TutorialState>()
        if let tutorial = try? modelContext.fetch(tutorialDescriptor).first,
           tutorial.currentTutorialStep == .completeBlock {
            tutorial.advanceStep()
            
            // Post notification to switch to Metrics tab
            NotificationCenter.default.post(name: NSNotification.Name("SwitchToMetricsTab"), object: nil)
        }
        
        self.activeBlockId = nil
        self.sessionStartTime = nil
        
        try? modelContext.save()
    }
    
    func isBlockActive(_ blockId: UUID) -> Bool {
        return activeBlockId == blockId
    }
    
    func hasActiveSession() -> Bool {
        return activeBlockId != nil
    }
}
