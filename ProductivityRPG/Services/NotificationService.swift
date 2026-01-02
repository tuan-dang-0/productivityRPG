import Foundation
import UserNotifications

struct NotificationService {
    static func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    static func sendAppBlockedNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Apps Blocked"
        content.body = "Tap here to unlock more time in Rewards"
        content.sound = .default
        content.categoryIdentifier = "APP_BLOCK"
        content.userInfo = ["deeplink": "productivityrpg://rewards"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        let request = UNNotificationRequest(
            identifier: "app-block-notification",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            }
        }
    }
    
    static func sendLevelUpNotification(level: Int, unlockedSprites: [UnlockableSprite]) {
        let content = UNMutableNotificationContent()
        content.title = "Level Up! 🎉"
        
        if unlockedSprites.isEmpty {
            content.body = "You reached level \(level)!"
        } else {
            let names = unlockedSprites.map { $0.name }.joined(separator: ", ")
            content.body = "Level \(level) reached! Unlocked: \(names)"
        }
        
        content.sound = .default
        content.categoryIdentifier = "LEVEL_UP"
        content.userInfo = ["deeplink": "productivityrpg://metrics"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        let request = UNNotificationRequest(
            identifier: "level-up-\(level)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    static func sendStreakNotification(days: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Streak Milestone! 🔥"
        content.body = "\(days) day streak! Keep it going!"
        content.sound = .default
        content.categoryIdentifier = "STREAK"
        content.userInfo = ["deeplink": "productivityrpg://quests"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        let request = UNNotificationRequest(
            identifier: "streak-\(days)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    static func sendLeetCodeValidation(bonusPercent: Int, details: String) {
        let content = UNMutableNotificationContent()
        content.title = "LeetCode Verified! ✓"
        content.body = "+\(bonusPercent)% bonus stats - \(details)"
        content.sound = .default
        content.categoryIdentifier = "LEETCODE"
        content.userInfo = ["deeplink": "productivityrpg://metrics"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        let request = UNNotificationRequest(
            identifier: "leetcode-validation-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}
