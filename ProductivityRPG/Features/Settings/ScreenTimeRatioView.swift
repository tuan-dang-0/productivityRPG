import SwiftUI
import SwiftData

struct ScreenTimeRatioView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [AppSettings]
    
    @State private var ratio: Double = 1.0
    
    private var appSettings: AppSettings? {
        settings.first
    }
    
    var body: some View {
        Form {
            Section(header: Text("Current Ratio")) {
                VStack(spacing: 16) {
                    Text("\(ratio, specifier: "%.1f")x")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.appAccent)
                    
                    Text("For every 1 hour of focused work")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Earn \(ratio * 60, specifier: "%.0f") minutes of screen time")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            
            Section {
                VStack(spacing: 12) {
                    HStack {
                        Text("0.25x")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("2.0x")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: $ratio, in: 0.25...2.0, step: 0.05)
                        .onChange(of: ratio) { _, _ in saveRatio() }
                }
                .padding(.vertical, 4)
            }
            
            Section(header: Text("Presets")) {
                Button(action: { setRatio(0.25) }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Very Strict")
                                .fontWeight(.semibold)
                            Text("4 hours work = 1 hour screen time")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if ratio == 0.25 {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.appAccent)
                        }
                    }
                }
                .foregroundColor(.primary)
                
                Button(action: { setRatio(0.5) }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Strict")
                                .fontWeight(.semibold)
                            Text("2 hours work = 1 hour screen time")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if ratio == 0.5 {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.appAccent)
                        }
                    }
                }
                .foregroundColor(.primary)
                
                Button(action: { setRatio(1.0) }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Relaxed")
                                .fontWeight(.semibold)
                            Text("1 hour work = 1 hour screen time")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if ratio == 1.0 {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.appAccent)
                        }
                    }
                }
                .foregroundColor(.primary)
            }
            
            Section(header: Text("Examples")) {
                ExampleRow(workMinutes: 30, ratio: ratio)
                ExampleRow(workMinutes: 60, ratio: ratio)
                ExampleRow(workMinutes: 120, ratio: ratio)
                ExampleRow(workMinutes: 240, ratio: ratio)
            }
            
            Section(header: Text("How It Works")) {
                Text("This ratio determines how many minutes of screen time you earn for each minute of focused work. A lower ratio encourages more work time, while a higher ratio is more generous with rewards.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Screen Time Ratio")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadRatio)
    }
    
    private func loadRatio() {
        if let settings = appSettings {
            ratio = settings.screenTimeRatio
        }
    }
    
    private func saveRatio() {
        if let settings = appSettings {
            settings.screenTimeRatio = ratio
            settings.updateTimestamp()
            try? modelContext.save()
        }
    }
    
    private func setRatio(_ newRatio: Double) {
        ratio = newRatio
        saveRatio()
    }
}

struct ExampleRow: View {
    let workMinutes: Int
    let ratio: Double
    
    private var earnedMinutes: Int {
        Int(Double(workMinutes) * ratio)
    }
    
    var body: some View {
        HStack {
            Text("\(workMinutes) min work")
                .foregroundColor(.secondary)
            Spacer()
            Image(systemName: "arrow.right")
                .foregroundColor(.secondary)
                .font(.caption)
            Spacer()
            Text("\(earnedMinutes) min screen time")
                .fontWeight(.semibold)
                .foregroundColor(.appAccent)
        }
        .font(.subheadline)
    }
}

#Preview {
    NavigationStack {
        ScreenTimeRatioView()
            .modelContainer(DataStore.shared)
    }
}
