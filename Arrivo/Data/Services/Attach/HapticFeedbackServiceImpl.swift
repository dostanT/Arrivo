//
//  HapticFeedbackServiceImpl.swift
//  Arrivo
//

import CoreHaptics
import UIKit

final class HapticFeedbackServiceImpl: HapticFeedbackProtocol {
    private var engine: CHHapticEngine?

    init() {
        prepareEngine()
    }

    private func prepareEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptic engine error:", error)
        }
    }

    func play(_ kind: HapticFeedbackKind) async {
        await MainActor.run {
            switch kind {
            case .lightImpact:
                impact(.light)
            case .softImpact:
                impact(.soft)
            case .success:
                notification(.success)
            case .error:
                notification(.error)
            case let .wave(durationSeconds):
                wave(duration: durationSeconds)
            }
        }
    }

    private func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    private func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }

    private func wave(duration: Double) {
        guard let engine else { return }
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [],
            relativeTime: 0,
            duration: duration
        )
        let attack = CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 0.1)
        let peak = CHHapticParameterCurve.ControlPoint(relativeTime: duration / 2, value: 1)
        let decay = CHHapticParameterCurve.ControlPoint(relativeTime: duration, value: 0.1)
        let curve = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: [attack, peak, decay],
            relativeTime: 0
        )
        do {
            let pattern = try CHHapticPattern(events: [event], parameterCurves: [curve])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print(error)
        }
    }
}
