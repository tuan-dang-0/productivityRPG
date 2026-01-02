import SwiftUI
import SwiftData
import FamilyControls

struct WelcomeOnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    
    @State private var username: String = ""
    @State private var currentPage = 0
    @State private var showError = false
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    var body: some View {
        NavigationStack {
            TabView(selection: $currentPage) {
                // Page 0: Username
                UsernameInputPage(username: $username, onContinue: {
                    withAnimation {
                        currentPage = 1
                    }
                })
                .tag(0)
                
                // Page 1: Calendar Permission
                CalendarPermissionPage(onContinue: {
                    withAnimation {
                        currentPage = 2
                    }
                }, onSkip: {
                    withAnimation {
                        currentPage = 2
                    }
                })
                .tag(1)
                
                // Page 2: App Blocking Permission
                AppBlockingPermissionPage(onContinue: {
                    withAnimation {
                        currentPage = 3
                    }
                }, onSkip: {
                    withAnimation {
                        currentPage = 3
                    }
                })
                .tag(2)
                
                // Page 3: LeetCode & Anki (optional)
                ProductivityLocksPage(onFinish: {
                    saveAndFinish()
                })
                .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("Please enter a username", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        }
    }
    
    private func saveAndFinish() {
        guard !username.isEmpty else {
            showError = true
            return
        }
        
        // Save username to profile
        if let profile = profile {
            profile.username = username
            try? modelContext.save()
        }
        
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        dismiss()
    }
}

// MARK: - Page 0: Username Input
struct UsernameInputPage: View {
    @Binding var username: String
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Welcome, Adventurer!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Choose a username for your journey")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 8) {
                TextField("Enter username", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                
                Text("This will be displayed on your character card")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: onContinue) {
                Text("Continue")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(username.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(12)
            }
            .disabled(username.isEmpty)
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Page 1: Calendar Permission
struct CalendarPermissionPage: View {
    let onContinue: () -> Void
    let onSkip: () -> Void
    
    @State private var isRequesting = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Calendar Sync")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Sync your time blocks to Apple Calendar")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 12) {
                FeatureBullet(icon: "checkmark.circle.fill", text: "See blocks in Calendar app and widgets")
                FeatureBullet(icon: "checkmark.circle.fill", text: "Silent reminders when blocks start")
                FeatureBullet(icon: "checkmark.circle.fill", text: "Works across all your Apple devices")
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal, 40)
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: {
                    requestCalendarPermission()
                }) {
                    HStack {
                        if isRequesting {
                            ProgressView()
                                .tint(.white)
                        }
                        Text(isRequesting ? "Requesting..." : "Enable Calendar Sync")
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .disabled(isRequesting)
                
                Button(action: onSkip) {
                    Text("Skip for now")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
    
    private func requestCalendarPermission() {
        isRequesting = true
        Task {
            let granted = await CalendarService.shared.requestCalendarAccess()
            await MainActor.run {
                UserDefaults.standard.set(granted, forKey: "calendarSyncEnabled")
                isRequesting = false
                onContinue()
            }
        }
    }
}

// MARK: - Page 2: App Blocking Permission
struct AppBlockingPermissionPage: View {
    let onContinue: () -> Void
    let onSkip: () -> Void
    
    @State private var isRequesting = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 80))
                .foregroundColor(.orange)
            
            Text("App Blocking")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Block distracting apps to stay focused")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 12) {
                FeatureBullet(icon: "checkmark.circle.fill", text: "Block social media and games")
                FeatureBullet(icon: "checkmark.circle.fill", text: "Earn screen time by completing blocks")
                FeatureBullet(icon: "checkmark.circle.fill", text: "Customize which apps to block")
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal, 40)
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: {
                    requestAppBlockingPermission()
                }) {
                    HStack {
                        if isRequesting {
                            ProgressView()
                                .tint(.white)
                        }
                        Text(isRequesting ? "Requesting..." : "Enable App Blocking")
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(12)
                }
                .disabled(isRequesting)
                
                Button(action: onSkip) {
                    Text("Skip for now")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
    
    private func requestAppBlockingPermission() {
        isRequesting = true
        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                await MainActor.run {
                    UserDefaults.standard.set(true, forKey: "appBlockingEnabled")
                    isRequesting = false
                    onContinue()
                }
            } catch {
                await MainActor.run {
                    UserDefaults.standard.set(false, forKey: "appBlockingEnabled")
                    isRequesting = false
                    onContinue()
                }
            }
        }
    }
}

// MARK: - Page 3: Optional Features
struct ProductivityLocksPage: View {
    let onFinish: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "sparkles")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("All Set!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Configure optional features in Settings")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "terminal.fill")
                        .foregroundColor(.blue)
                        .frame(width: 30)
                    Text("LeetCode Daily Requirements")
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "books.vertical.fill")
                        .foregroundColor(.green)
                        .frame(width: 30)
                    Text("Anki Daily Requirements")
                    Spacer()
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: onFinish) {
                Text("Start Your Journey")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Helper Views
struct FeatureBullet: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .frame(width: 20)
            Text(text)
                .font(.callout)
            Spacer()
        }
    }
}

#Preview {
    WelcomeOnboardingView()
        .modelContainer(DataStore.shared)
}
