//
//  SoundPlaybackProtocol.swift
//  Arrivo
//

protocol SoundPlaybackProtocol: Sendable {
    func playAlarmSound() async
}
