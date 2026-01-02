import SwiftUI
import SwiftData
import FamilyControls

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [AppSettings]
    @Query private var profiles: [UserProfile]
    @Query private var tutorialStates: [TutorialState]
    
    private var appSettings: AppSettings? {
        settings.first
    }
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    private var tutorialState: TutorialState? {
        tutorialStates.first
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Calendar & Scheduling Section
                Section(header: Text("Calendar & Scheduling")) {
                    if let settings = appSettings {
                        Toggle("Calendar Sync", isOn: Binding(
                            get: { settings.calendarSyncEnabled },
                            set: { newValue in
                                settings.calendarSyncEnabled = newValue
                                settings.updateTimestamp()
                                try? modelContext.save()
                                UserDefaults.standard.set(newValue, forKey: "calendarSyncEnabled")
                            }
                        ))
                        .onAppear {
                            syncSettingsWithPermissions(settings: settings)
                        }
                        
                        if settings.calendarSyncEnabled {
                            Text("Time blocks will sync to your calendar with reminders")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Productivity Locks Section
                Section(header: Text("Productivity Locks")) {
                    NavigationLink {
                        LeetCodeRequirementsView()
                    } label: {
                        HStack {
                            Image(systemName: "terminal.fill")
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("LeetCode Daily Requirement")
                                if let settings = appSettings, settings.leetcodeEnabled {
                                    Text("Goal: \(settings.leetcodeDailyGoal) problems")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("Not configured")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    
                    NavigationLink {
                        AnkiRequirementsView()
                    } label: {
                        HStack {
                            Image(systemName: "books.vertical.fill")
                                .foregroundColor(.green)
                                .frame(width: 30)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Anki Daily Requirement")
                                Text("Coming Soon")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .disabled(true)
                    .opacity(0.5)
                }
                
                // Screen Time & Rewards Section
                Section(header: Text("Screen Time & Rewards")) {
                    if let settings = appSettings {
                        Toggle("App Blocking", isOn: Binding(
                            get: { settings.appBlockingEnabled },
                            set: { newValue in
                                if newValue {
                                    requestScreenTimeAccess(settings: settings)
                                } else {
                                    settings.appBlockingEnabled = false
                                    settings.updateTimestamp()
                                    try? modelContext.save()
                                    UserDefaults.standard.set(false, forKey: "appBlockingEnabled")
                                }
                            }
                        ))
                        .onAppear {
                            syncSettingsWithPermissions(settings: settings)
                        }
                        
                        if settings.appBlockingEnabled {
                            Text("Apps are blocked when reward time runs out")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        NavigationLink {
                            ScreenTimeRatioView()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Screen Time Ratio")
                                    Text("Currently: \(settings.screenTimeRatio, specifier: "%.1f")x")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                        }
                    }
                }
                
                // Appearance Section
                Section(header: Text("Appearance")) {
                    NavigationLink {
                        AccentColorView()
                    } label: {
                        HStack {
                            Circle()
                                .fill(Color.appAccent)
                                .frame(width: 24, height: 24)
                            
                            Text("Accent Color")
                            
                            Spacer()
                        }
                    }
                }
                
                // Profile Section
                Section(header: Text("Profile")) {
                    HStack {
                        Text("Username")
                        Spacer()
                        Text(profile?.username ?? "Not set")
                            .foregroundColor(.secondary)
                    }
                }
                
                // About Section
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Button(role: .destructive) {
                        // TODO: Implement reset
                    } label: {
                        Text("Reset All Data")
                    }
                    .disabled(true)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .overlay {
                if let tutorial = tutorialState, tutorial.isActive, tutorial.currentTutorialStep == .viewSettings {
                    TutorialOverlay(
                        step: .viewSettings,
                        onSkip: {
                            tutorial.advanceStep()
                            try? modelContext.save()
                        }
                    )
                    .zIndex(999)
                }
            }
        }
        .padding(.bottom, 100)
    }
    
    private func syncSettingsWithPermissions(settings: AppSettings) {
        // Check Calendar permission
        let calendarEnabled = UserDefaults.standard.bool(forKey: "calendarSyncEnabled")
        if calendarEnabled != settings.calendarSyncEnabled {
            settings.calendarSyncEnabled = calendarEnabled
        }
        
        // Check Screen Time authorization
        let authStatus = AuthorizationCenter.shared.authorizationStatus
        if authStatus == .approved {
            let appBlockingEnabled = UserDefaults.standard.bool(forKey: "appBlockingEnabled")
            if appBlockingEnabled != settings.appBlockingEnabled {
                settings.appBlockingEnabled = appBlockingEnabled
            }
        }
        
        try? modelContext.save()
    }
    
    private func requestScreenTimeAccess(settings: AppSettings) {
        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                await MainActor.run {
                    settings.appBlockingEnabled = true
                    settings.updateTimestamp()
                    try? modelContext.save()
                    UserDefaults.standard.set(true, forKey: "appBlockingEnabled")
                }
            } catch {
                print("Screen Time authorization failed: \(error)")
                await MainActor.run {
                    settings.appBlockingEnabled = false
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(DataStore.shared)
}
