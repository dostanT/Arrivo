//
//  SoundPlaybackServiceImpl.swift
//  Arrivo
//

import AVFoundation

final class SoundPlaybackServiceImpl: SoundPlaybackProtocol {
    private var player: AVAudioPlayer?
    
    init() {}
    
    func playAlarmSound() async {
        await MainActor.run { [weak self] in
            self?.setupAudioSession()
            guard let url = Bundle.main.url(forResource: "lesiakower-chiptune-alarm-clock", withExtension: "mp3") else {
                return
            }
            do {
                self?.player = try AVAudioPlayer(contentsOf: url)
                self?.player?.numberOfLoops = -1
                self?.player?.play()
            } catch {
                print("Play error:", error)
            }
        }
    }
    
    func play(url: URL) async {
        await MainActor.run { [weak self] in
            self?.setupAudioSession()
            do {
                self?.player = try AVAudioPlayer(contentsOf: url)
                self?.player?.prepareToPlay()
                self?.player?.play()
            } catch {
                print("Ошибка воспроизведения:", error)
            }
        }
    }
    
    func stop() {
        player?.stop()
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
