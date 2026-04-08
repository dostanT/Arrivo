//
//  SoundPlaybackServiceImpl.swift
//  Arrivo
//

import AVFoundation

final class SoundPlaybackServiceImpl: SoundPlaybackProtocol {
    private var player: AVAudioPlayer?
    private let melodyRepository: MelodyURLRepositoryProtocol = MelodyURLRepository()
    
    init() {}
    
    func playAlarmSound() async {
        await MainActor.run { [weak self] in
            self?.setupAudioSession()
            if let url = self?.melodyRepository.loadMelodyURL() {
                self?.play(url: url)
            } else if let url = Bundle.main.url(forResource: "lesiakower-chiptune-alarm-clock", withExtension: "mp3"){
                self?.play(url: url)
            } else {
                return
            }
        }
    }
    
    func play(url: URL) {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("Ошибка воспроизведения:", error)
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
