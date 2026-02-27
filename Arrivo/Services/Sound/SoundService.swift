//
//  SoundService.swift
//  ArrivoNuvuCollection
//
//  Created by Dostan Turlybek on 22.02.2026.
//

import AVFoundation

class SoundService {
    static let shared = SoundService()
    private var player: AVAudioPlayer?

    private init() {}

    func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("Audio session error:", error)
        }
    }

    func play() {
        setupAudioSession()
        guard let url = Bundle.main.url(forResource: "lesiakower-chiptune-alarm-clock", withExtension: "mp3") else {
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1 // infinite loop
            player?.play()
        } catch {
            print("Play error:", error)
        }
    }

    func stop() {
        player?.stop()
    }
}
