import SwiftUI

struct AnkiRequirementsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "books.vertical.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Anki Integration")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Coming Soon")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Daily Anki card requirements will be available in a future update")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Anki Requirements")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AnkiRequirementsView()
    }
}
