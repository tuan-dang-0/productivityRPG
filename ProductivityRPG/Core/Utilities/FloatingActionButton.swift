import SwiftUI

struct FloatingActionButton: View {
    let action: () -> Void
    let hasClaimable: Bool
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.appAccent)
                    .frame(width: 50, height: 50)
                    .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
                
                Image(systemName: "book.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                
                // Claimable badge
                if hasClaimable {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Image(systemName: "exclamationmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .offset(x: 18, y: -18)
                }
            }
        }
    }
}
