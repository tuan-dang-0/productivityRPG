import Foundation
import SwiftData

@Model
final class TutorialState {
    var id: UUID
    var hasCompletedFirstBlock: Bool
    var currentTutorialStep: TutorialStep?
    var isActive: Bool
    
    init(
        id: UUID = UUID(),
        hasCompletedFirstBlock: Bool = false,
        currentTutorialStep: TutorialStep? = nil,
        isActive: Bool = false
    ) {
        self.id = id
        self.hasCompletedFirstBlock = hasCompletedFirstBlock
        self.currentTutorialStep = currentTutorialStep
        self.isActive = isActive
    }
    
    func startTutorial() {
        isActive = true
        currentTutorialStep = .tapAddBlock
    }
    
    func advanceStep() {
        guard let current = currentTutorialStep else { return }
        
        switch current {
        case .tapAddBlock:
            currentTutorialStep = .editAndSave
        case .editAndSave:
            currentTutorialStep = .completeBlock
        case .completeBlock:
            currentTutorialStep = .viewMetricsStats
        case .viewMetricsStats:
            currentTutorialStep = .viewRewards
        case .viewMetricsSubcategories:
            currentTutorialStep = .viewRewards
        case .viewMetricsCustomization:
            currentTutorialStep = .viewRewards
        case .viewRewards:
            currentTutorialStep = .viewSettings
        case .viewSettings:
            currentTutorialStep = .tutorialComplete
        case .tutorialComplete:
            completeTutorial()
        }
    }
    
    func completeTutorial() {
        hasCompletedFirstBlock = true
        currentTutorialStep = nil
        isActive = false
    }
}

enum TutorialStep: String, Codable {
    case tapAddBlock = "Tap the + button below to create your first time block"
    case editAndSave = "Try selecting the Gym category, then tap Save to create your block"
    case completeBlock = "As you can see, the block has a Strength icon. Let's complete this time block and see what happens!"
    case viewMetricsStats = "As you can see, your strength stat has increased! Here you can see your character's stats and XP progress. Scroll down to create custom subcategories. Tap your character to customize sprites and backgrounds as you level up. When ready, switch to the Rewards tab!"
    case viewMetricsSubcategories = "Here you can create custom subcategories that correlate to the stat you want to increase. Try creating activities that match your goals!"
    case viewMetricsCustomization = "As you level up, you'll unlock new character sprites and backgrounds. Customize your profile to showcase your progress!"
    case viewRewards = "In Rewards, you can enable app blocking to stay focused. Earn screen time minutes by completing blocks and claiming daily quest rewards. Switch to the settings tab next!"
    case viewSettings = "Finally, here are optional settings. You can customize the accent color, manage your calendar sync, and adjust various preferences"
    case tutorialComplete = "You're all set! Start creating time blocks, complete them to gain XP, and watch your character grow. Good luck on your journey!"
    
    var title: String {
        switch self {
        case .tapAddBlock:
            return "Create Your First Block"
        case .editAndSave:
            return "Complete Your Block"
        case .completeBlock:
            return "Understanding Your Block"
        case .viewMetricsStats:
            return "Stats & Progression"
        case .viewMetricsSubcategories:
            return "Subcategories"
        case .viewMetricsCustomization:
            return "Customization"
        case .viewRewards:
            return "Screen Time Rewards"
        case .viewSettings:
            return "Settings"
        case .tutorialComplete:
            return "Tutorial Complete!"
        }
    }
    
    var description: String {
        return self.rawValue
    }
}

enum TutorialHighlight {
    case addButton
    case blockEditor
    case blockCard
    case metricsTab
    case rewardsTab
    case settingsTab
    case none
}
