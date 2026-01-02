import Foundation
import AVFoundation
import Combine

@Observable
class MusicPlayerService {
    static let shared = MusicPlayerService()
    
    private var audioPlayer: AVAudioPlayer?
    private var currentSongIndex: Int = 0
    
    var isPlaying: Bool = false
    var isMuted: Bool = false
    var volume: Float = 0.5 {
        didSet {
            audioPlayer?.volume = isMuted ? 0 : volume
        }
    }
    
    let songs: [Song] = [
        Song(name: "Arcane Final Phase", filename: "Arcane Final Phase"),
        Song(name: "Cursed Cathedral", filename: "Cursed Cathedral_ Abyss Gate"),
        Song(name: "Pastel Village Morning", filename: "Pastel Village Morning"),
        Song(name: "Woodland Trail", filename: "Woodland Trail, Sunlit Canopy")
    ]
    
    var currentSong: Song? {
        guard currentSongIndex < songs.count else { return nil }
        return songs[currentSongIndex]
    }
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func playSong(at index: Int) {
        guard index < songs.count else { return }
        currentSongIndex = index
        
        let song = songs[index]
        guard let url = Bundle.main.url(forResource: song.filename, withExtension: "mp3") else {
            print("Could not find song: \(song.filename)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.volume = isMuted ? 0 : volume
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Failed to play song: \(error)")
        }
    }
    
    func pause() {
        audioPlayer?.pause()
        isPlaying = false
    }
    
    func resume() {
        audioPlayer?.play()
        isPlaying = true
    }
    
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            if audioPlayer == nil {
                playSong(at: currentSongIndex)
            } else {
                resume()
            }
        }
    }
    
    func toggleMute() {
        isMuted.toggle()
        audioPlayer?.volume = isMuted ? 0 : volume
    }
    
    func nextSong() {
        currentSongIndex = (currentSongIndex + 1) % songs.count
        playSong(at: currentSongIndex)
    }
    
    func previousSong() {
        currentSongIndex = (currentSongIndex - 1 + songs.count) % songs.count
        playSong(at: currentSongIndex)
    }
}

struct Song: Identifiable {
    let id = UUID()
    let name: String
    let filename: String
}
