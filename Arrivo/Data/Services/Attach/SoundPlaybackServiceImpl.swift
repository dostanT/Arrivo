//
//  SoundPlaybackServiceImpl.swift
//  Arrivo
//

import AVFoundation

final class SoundPlaybackServiceImpl: SoundPlaybackProtocol {
    private var player: AVAudioPlayer?

    init() {}

    func playAlarmSound() async {
        await MainActor.run {
            setupAudioSession()
            guard let url = Bundle.main.url(forResource: "lesiakower-chiptune-alarm-clock", withExtension: "mp3") else {
                return
            }
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.numberOfLoops = -1
                player?.play()
            } catch {
                print("Play error:", error)
            }
        }
    }

    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("Audio session error:", error)
        }
    }
}
