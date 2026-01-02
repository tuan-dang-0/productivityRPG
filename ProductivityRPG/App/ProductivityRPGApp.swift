import SwiftUI
import SwiftData

@main
struct ProductivityRPGApp: App {
    let modelContainer: ModelContainer
    @State private var sessionService = FocusSessionService()
    
    init() {
        self.modelContainer = DataStore.createModelContainer()
        
        let modelContext = ModelContext(modelContainer)
        SeedData.seedIfNeeded(modelContext: modelContext)
        
        AppBlockingService.initialize(modelContext: modelContext)
        AppBlockingService.applyBlockedApps(modelContext: modelContext)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
                .environment(sessionService)
                .font(.playfair(16))
        }
    }
}

struct ContentView: View {
    @State private var showQuestBook = false
    @State private var showMusicPlayer = false
    @State private var selectedTab = 0
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    @State private var showFirstLoginBanner = false
    @Environment(\.modelContext) private var modelContext
    @Query private var logins: [DailyLogin]
    @Query private var tutorialStates: [TutorialState]
    @Query private var achievements: [Achievement]
    @Query private var quests: [DailyQuest]
    
    private var loginTracker: DailyLogin? {
        logins.first
    }
    
    private var tutorialState: TutorialState? {
        tutorialStates.first
    }
    
    private var hasClaimableItems: Bool {
        // Check achievements
        let hasClaimableAchievements = achievements.contains { $0.canClaim }
        
        // Check daily quests (only today's)
        let today = DailyQuest.normalizeToDay(Date())
        let hasClaimableQuests = quests.contains { quest in
            DailyQuest.normalizeToDay(quest.date) == today && quest.canClaim
        }
        
        return hasClaimableAchievements || hasClaimableQuests
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ZStack(alignment: .top) {
                TabView(selection: $selectedTab) {
                UnifiedScheduleView()
                    .tabItem {
                        Label("Schedule", systemImage: "calendar.badge.clock")
                    }
                    .tag(0)
                
                NewMetricsView()
                    .tabItem {
                        Label("Metrics", systemImage: "chart.bar")
                    }
                    .tag(1)
                
                RewardsView()
                    .tabItem {
                        Label("Rewards", systemImage: "gift")
                    }
                    .tag(2)
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
                    .tag(3)
                }
                .onChange(of: selectedTab) { _, newTab in
                    handleTabChange(newTab)
                }
                .preferredColorScheme(.dark)
                .onAppear {
                    let appearance = UITabBarAppearance()
                    appearance.configureWithTransparentBackground()
                    appearance.backgroundColor = UIColor.black.withAlphaComponent(0.8)
                    UITabBar.appearance().standardAppearance = appearance
                    UITabBar.appearance().scrollEdgeAppearance = appearance
                    
                    // Only check daily login if onboarding is completed
                    if UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
                        checkDailyLogin()
                    }
                    
                    // Listen for tutorial tab switch notifications
                    NotificationCenter.default.addObserver(
                        forName: NSNotification.Name("SwitchToMetricsTab"),
                        object: nil,
                        queue: .main
                    ) { _ in
                        selectedTab = 1
                    }
                }
                .onOpenURL { url in
                    handleDeepLink(url)
                }
                
                // First login banner
                if showFirstLoginBanner {
                    FirstLoginBanner(isVisible: $showFirstLoginBanner)
                        .zIndex(1)
                        .padding(.top, 50)
                }
                
                // Tutorial complete overlay
                if let tutorial = tutorialState, tutorial.isActive, tutorial.currentTutorialStep == .tutorialComplete {
                    TutorialOverlay(
                        step: .tutorialComplete,
                        onSkip: {
                            tutorial.completeTutorial()
                            try? modelContext.save()
                        }
                    )
                    .zIndex(1000)
                }
            }
            
            HStack(spacing: 16) {
                FloatingActionButton(action: {
                    showQuestBook = true
                }, hasClaimable: hasClaimableItems)
                
                Spacer()
                
                FloatingMusicButton {
                    showMusicPlayer = true
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 70)
        }
        .sheet(isPresented: $showQuestBook) {
            QuestBookView()
        }
        .sheet(isPresented: $showMusicPlayer) {
            MusicPlayerView()
        }
        .sheet(isPresented: $showOnboarding) {
            WelcomeOnboardingView()
        }
        .onChange(of: showOnboarding) { oldValue, newValue in
            // When onboarding sheet closes, check daily login and start tutorial
            if oldValue == true && newValue == false {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    checkDailyLogin()
                    startTutorialIfNeeded()
                }
            }
        }
    }
    
    private func checkDailyLogin() {
        // Fetch or create DailyLogin directly instead of relying on @Query
        let descriptor = FetchDescriptor<DailyLogin>()
        let trackers = (try? modelContext.fetch(descriptor)) ?? []
        
        let tracker: DailyLogin
        if let existing = trackers.first {
            tracker = existing
        } else {
            // Create new tracker if none exists
            tracker = DailyLogin()
            modelContext.insert(tracker)
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Check if already logged in today
        let alreadyLoggedIn = tracker.loginDates.contains { date in
            calendar.isDate(date, inSameDayAs: today)
        }
        
        if !alreadyLoggedIn {
            // Record the login
            tracker.recordLogin()
            
            // Update login achievements immediately
            updateLoginAchievements(totalLogins: tracker.totalLogins)
            
            try? modelContext.save()
        }
        
        // Don't show banner if onboarding hasn't been completed
        guard UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") else {
            return
        }
        
        // Show banner only if we just logged in
        if !alreadyLoggedIn {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    showFirstLoginBanner = true
                }
                
                // Auto-dismiss after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        showFirstLoginBanner = false
                    }
                }
            }
        }
    }
    
    private func updateLoginAchievements(totalLogins: Int) {
        // Fetch all achievements and filter for login days
        let descriptor = FetchDescriptor<Achievement>()
        guard let allAchievements = try? modelContext.fetch(descriptor) else { return }
        
        let loginAchievements = allAchievements.filter { $0.category == .loginDays }
        
        for achievement in loginAchievements {
            achievement.currentProgress = totalLogins
            if totalLogins >= achievement.requirement && !achievement.isUnlocked {
                achievement.isUnlocked = true
                achievement.unlockedDate = Date()
            }
        }
        
        // Ensure changes are saved
        try? modelContext.save()
    }
    
    private func startTutorialIfNeeded() {
        guard let tutorial = tutorialState else { return }
        
        // Only start tutorial if user hasn't completed their first block
        if !tutorial.hasCompletedFirstBlock && !tutorial.isActive {
            tutorial.startTutorial()
            try? modelContext.save()
        }
    }
    
    private func handleTabChange(_ newTab: Int) {
        guard let tutorial = tutorialState, tutorial.isActive else { return }
        
        // Auto-advance tutorial when switching to appropriate tab
        switch tutorial.currentTutorialStep {
        case .completeBlock:
            if newTab == 1 { // Metrics tab
                tutorial.advanceStep()
                try? modelContext.save()
            }
        case .viewMetricsStats:
            if newTab == 2 { // Rewards tab
                tutorial.advanceStep()
                try? modelContext.save()
            }
        case .viewRewards:
            if newTab == 3 { // Settings tab
                tutorial.advanceStep()
                try? modelContext.save()
            }
        default:
            break
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "productivityrpg" else { return }
        
        switch url.host {
        case "schedule":
            selectedTab = 0
        case "metrics":
            selectedTab = 1
        case "rewards":
            selectedTab = 2
        case "settings":
            selectedTab = 3
        case "quests":
            showQuestBook = true
        default:
            break
        }
    }
}
