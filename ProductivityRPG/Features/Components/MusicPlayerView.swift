import SwiftUI

struct MusicPlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var musicService = MusicPlayerService.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Current Song Display
                if let currentSong = musicService.currentSong {
                    VStack(spacing: 12) {
                        Image(systemName: "music.note")
                            .font(.system(size: 60))
                            .foregroundColor(.appAccent)
                            .padding(.top, 30)
                        
                        Text(currentSong.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Text(musicService.isPlaying ? "Now Playing" : "Paused")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color(.systemGray6))
                }
                
                // Playback Controls
                HStack(spacing: 40) {
                    Button(action: { musicService.previousSong() }) {
                        Image(systemName: "backward.fill")
                            .font(.title)
                            .foregroundColor(.appAccent)
                    }
                    
                    Button(action: { musicService.togglePlayPause() }) {
                        Image(systemName: musicService.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.appAccent)
                    }
                    
                    Button(action: { musicService.nextSong() }) {
                        Image(systemName: "forward.fill")
                            .font(.title)
                            .foregroundColor(.appAccent)
                    }
                }
                .padding(.vertical, 30)
                
                // Volume Control
                VStack(spacing: 16) {
                    HStack {
                        Button(action: { musicService.toggleMute() }) {
                            Image(systemName: musicService.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                .font(.title2)
                                .foregroundColor(.appAccent)
                        }
                        
                        Slider(value: Binding(
                            get: { musicService.volume },
                            set: { newValue in
                                musicService.volume = newValue
                                if musicService.isMuted {
                                    musicService.isMuted = false
                                }
                            }
                        ), in: 0...1)
                        
                        Text("\(Int(musicService.volume * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 40)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 20)
                .background(Color(.systemGray6))
                
                // Song List
                List {
                    Section(header: Text("Playlist")) {
                        ForEach(Array(musicService.songs.enumerated()), id: \.element.id) { index, song in
                            Button(action: {
                                musicService.playSong(at: index)
                            }) {
                                HStack {
                                    Image(systemName: "music.note")
                                        .foregroundColor(.appAccent)
                                    
                                    Text(song.name)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    if musicService.currentSong?.id == song.id && musicService.isPlaying {
                                        Image(systemName: "speaker.wave.2.fill")
                                            .foregroundColor(.appAccent)
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Music Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    MusicPlayerView()
}
