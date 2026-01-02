import Foundation

struct RewardCalculator {
    static func calculateCompletion(tasks: [TaskItem]) -> Double {
        guard !tasks.isEmpty else {
            return 0.0
        }
        
        let totalWeight = tasks.reduce(0.0) { $0 + $1.weight }
        guard totalWeight > 0 else {
            return 0.0
        }
        
        let completedWeight = tasks
            .filter { $0.isCompleted }
            .reduce(0.0) { $0 + $1.weight }
        
        return completedWeight / totalWeight
    }
    
    static func calculateEarnedMinutes(baseRewardMinutes: Int, completionPercent: Double) -> Int {
        let earned = Double(baseRewardMinutes) * completionPercent
        return Int(earned)
    }
}
