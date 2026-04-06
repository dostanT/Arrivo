//
//  HapticFeedbackProtocol.swift
//  Arrivo
//

enum HapticFeedbackKind: Sendable {
    case lightImpact
    case softImpact
    case success
    case error
    case wave(durationSeconds: Double)
}

protocol HapticFeedbackProtocol: Sendable {
    func play(_ kind: HapticFeedbackKind) async
}
