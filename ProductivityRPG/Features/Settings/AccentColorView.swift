import SwiftUI
import SwiftData

struct AccentColorView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [AppSettings]
    
    private var appSettings: AppSettings? {
        settings.first
    }
    
    let accentColors: [(name: String, hex: String)] = [
        ("Blue", "007AFF"),
        ("Purple", "AF52DE"),
        ("Pink", "FF2D55"),
        ("Red", "FF3B30"),
        ("Orange", "FF9500"),
        ("Yellow", "FFCC00"),
        ("Green", "34C759"),
        ("Teal", "5AC8FA"),
        ("Indigo", "5856D6"),
        ("Mint", "00C7BE")
    ]
    
    var body: some View {
        Form {
            Section(header: Text("Current Accent Color")) {
                if let settings = appSettings {
                    HStack {
                        Circle()
                            .fill(Color(hex: settings.accentColorHex))
                            .frame(width: 40, height: 40)
                        
                        Text(colorName(for: settings.accentColorHex))
                            .font(.headline)
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
            
            Section(header: Text("Choose Accent Color")) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 16) {
                    ForEach(accentColors, id: \.hex) { colorItem in
                        Button(action: {
                            setAccentColor(colorItem.hex)
                        }) {
                            VStack(spacing: 8) {
                                Circle()
                                    .fill(Color(hex: colorItem.hex))
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                appSettings?.accentColorHex == colorItem.hex ? Color.primary : Color.clear,
                                                lineWidth: 3
                                            )
                                    )
                                
                                Text(colorItem.name)
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 8)
            }
            
            Section(header: Text("Preview")) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.appAccent)
                    Text("Accent color is used throughout the app")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("Accent Color")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func colorName(for hex: String) -> String {
        accentColors.first(where: { $0.hex == hex })?.name ?? "Custom"
    }
    
    private func setAccentColor(_ hex: String) {
        guard let settings = appSettings else { return }
        settings.accentColorHex = hex
        settings.updateTimestamp()
        try? modelContext.save()
        
        // Sync to UserDefaults for Color.appAccent
        UserDefaults.standard.set(hex, forKey: "appAccentColorHex")
    }
}

#Preview {
    NavigationStack {
        AccentColorView()
            .modelContainer(DataStore.shared)
    }
}
