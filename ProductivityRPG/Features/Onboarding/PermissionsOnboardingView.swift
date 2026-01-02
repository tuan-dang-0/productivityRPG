import SwiftUI
import FamilyControls

struct PermissionsOnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var calendarEnabled = false
    @State private var screenTimeEnabled = false
    @State private var showingScreenTimePicker = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Welcome to ProductivityRPG!")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("Enable optional features to enhance your productivity experience")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 32)
                    
                    // Calendar Sync
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .frame(width: 40)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Calendar Sync")
                                    .font(.headline)
                                
                                Text("Sync time blocks to Apple Calendar with silent reminders")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $calendarEnabled)
                                .labelsHidden()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        if calendarEnabled {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("Benefits:")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    BulletPoint(text: "See blocks in Calendar app, widgets, and Watch")
                                    BulletPoint(text: "Silent notifications when blocks start")
                                    BulletPoint(text: "Syncs across all your Apple devices")
                                    BulletPoint(text: "Siri can read your schedule")
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Screen Time / App Blocking
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "hourglass.badge.plus")
                                .font(.title2)
                                .foregroundColor(.orange)
                                .frame(width: 40)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("App Blocking")
                                    .font(.headline)
                                
                                Text("Block distracting apps to stay focused during work blocks")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $screenTimeEnabled)
                                .labelsHidden()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        if screenTimeEnabled {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("Benefits:")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    BulletPoint(text: "Block social media and games during focus time")
                                    BulletPoint(text: "Earn more XP by staying focused")
                                    BulletPoint(text: "Customize which apps to block")
                                    BulletPoint(text: "Automatic blocking during time blocks")
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Info Note
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        
                        Text("You can change these settings anytime in the app")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Continue") {
                        applyPermissions()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func applyPermissions() {
        // Save preferences
        UserDefaults.standard.set(calendarEnabled, forKey: "calendarSyncEnabled")
        UserDefaults.standard.set(screenTimeEnabled, forKey: "appBlockingEnabled")
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        // Request calendar permission if enabled
        if calendarEnabled {
            Task {
                _ = await CalendarService.shared.requestCalendarAccess()
            }
        }
        
        // Request Screen Time permission if enabled
        if screenTimeEnabled {
            Task {
                do {
                    try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                } catch {
                    print("Screen Time authorization failed: \(error)")
                }
            }
        }
        
        dismiss()
    }
}

struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
            Text(text)
            Spacer()
        }
    }
}

#Preview {
    PermissionsOnboardingView()
}
