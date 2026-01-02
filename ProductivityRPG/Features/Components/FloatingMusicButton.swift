import SwiftUI

struct FloatingMusicButton: View {
    let action: () -> Void
    @State private var musicService = MusicPlayerService.shared
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.appAccent)
                    .frame(width: 50, height: 50)
                    .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
                
                Image(systemName: musicService.isPlaying ? "music.note" : "music.note.list")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
            }
        }
    }
}
