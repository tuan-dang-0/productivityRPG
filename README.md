# ProductivityRPG

A gamified productivity app for iOS that transforms time blocking and task management into an engaging RPG experience. Complete tasks, level up your character, earn rewards, and unlock new customization options.

## 🎮 Features

### Core Functionality
- **Time Blocking**: Schedule and manage your day with customizable time blocks
- **RPG Progression**: Earn XP and level up across 4 stat categories (Strength, Agility, Intelligence, Artistry)
- **Pomodoro Timer**: Built-in focus timer with break management
- **Task Management**: Attach tasks to time blocks and track completion
- **Character Customization**: Unlock and customize your pixel character and backgrounds

### Gamification
- **Daily Quests**: Complete daily challenges for bonus rewards
- **Achievements**: Unlock achievements by hitting milestones
- **Streak Tracking**: Maintain daily login and completion streaks
- **Reward System**: Earn minutes to unlock blocked apps

### Productivity Tools
- **App Blocking**: Block distracting apps using iOS Screen Time API
- **LeetCode Integration**: Validate coding practice (optional)
- **Music Player**: In-app background music for focus sessions
- **Statistics Tracking**: View your progress over time with graphs

## 📱 Requirements

- **iOS**: 17.0 or later
- **Xcode**: 15.0 or later
- **Swift**: 5.9 or later

## 🛠 Technology Stack

- **UI Framework**: SwiftUI
- **Persistence**: SwiftData
- **Special APIs**:
  - FamilyControls (Screen Time API for app blocking)
  - ManagedSettings (App shield management)
  - EventKit (Calendar integration - optional)

## 📁 Project Structure

```
ProductivityRPG/
├── App/
│   └── ProductivityRPGApp.swift          # Main app entry point
├── Core/
│   ├── Models/                           # SwiftData models
│   ├── Persistence/                      # Database configuration
│   └── Utilities/                        # Extensions and helpers
├── Features/
│   ├── Today/                            # Today view and task management
│   ├── Schedule/                         # Weekly schedule view
│   ├── Metrics/                          # Character stats and progression
│   ├── Rewards/                          # Reward wallet and app blocking
│   ├── Settings/                         # App settings and customization
│   ├── QuestBook/                        # Achievements and quests
│   ├── Onboarding/                       # First-time user experience
│   └── Components/                       # Reusable UI components
└── Services/                             # Business logic and services
```

## 🎯 Core Models

- **TimeBlock**: Scheduled time periods for productivity
- **TaskItem**: Individual tasks within time blocks
- **Category/Subcategory**: Organizational structure for activities
- **UserProfile**: Player character and progression data
- **RewardWallet**: Accumulated reward minutes
- **DailyQuest**: Daily challenges and objectives
- **Achievement**: Unlockable achievements
- **UnlockableSprite**: Character customization options

## 🚀 Getting Started

1. Clone the repository
2. Open `ProductivityRPG.xcodeproj` in Xcode
3. Build and run (⌘R)
4. Complete the onboarding flow
5. Start creating time blocks and completing tasks!

## 🎨 Customization

The app uses the **Playfair Display** font for a sophisticated look. Custom fonts and colors can be modified in:
- `Core/Utilities/FontExtension.swift` - Font configuration
- `Core/Utilities/ColorExtensions.swift` - Color palette

## 📊 Data Persistence

All data is persisted locally using SwiftData. Your progress includes:
- Time blocks and task history
- Character level, XP, and stats
- Unlocked sprites and customizations
- Streaks, achievements, and quest progress
- Reward minutes and blocked app selections

See `DATA_PERSISTENCE_GUIDE.md` for more details on data management during development.

## 🔒 Permissions

The app may request the following permissions:
- **Screen Time**: Required for app blocking features
- **Notifications**: For focus session reminders (optional)
- **Calendar**: For time block integration (optional)

## 📄 License

This is a personal project. All rights reserved.

## 🤝 Contributing

This is a personal productivity app and is not currently accepting contributions.
