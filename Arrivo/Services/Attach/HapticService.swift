//
//  HapticService.swift
//  Arrivo
//

import UIKit
import CoreHaptics

final class HapticService {

    static let shared = HapticService()

    private var engine: CHHapticEngine?

    private init() {
        prepareEngine()
    }

    // MARK: - Engine

    private func prepareEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptic engine error:", error)
        }
    }
    
    func wavePattern(waves: Int, waveDuration: Double) {
        guard let engine else { return }

        let totalDuration = Double(waves) * waveDuration

        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [],
            relativeTime: 0,
            duration: totalDuration
        )

        var points: [CHHapticParameterCurve.ControlPoint] = []

        for i in 0..<waves {
            let start = Double(i) * waveDuration
            let mid = start + waveDuration / 2
            let end = start + waveDuration

            points.append(.init(relativeTime: start, value: 0.1))
            points.append(.init(relativeTime: mid, value: 1.0))
            points.append(.init(relativeTime: end, value: 0.1))
        }

        let curve = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: points,
            relativeTime: 0
        )

        do {
            let pattern = try CHHapticPattern(
                events: [event],
                parameterCurves: [curve]
            )

            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)

        } catch {
            print(error)
        }
    }
    
    func wave(duration: Double) {
        guard let engine else { return }

        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [],
            relativeTime: 0,
            duration: duration
        )

        let attack = CHHapticParameterCurve.ControlPoint(
            relativeTime: 0,
            value: 0.1
        )

        let peak = CHHapticParameterCurve.ControlPoint(
            relativeTime: duration / 2,
            value: 1
        )

        let decay = CHHapticParameterCurve.ControlPoint(
            relativeTime: duration,
            value: 0.1
        )

        let curve = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: [attack, peak, decay],
            relativeTime: 0
        )

        do {
            let pattern = try CHHapticPattern(
                events: [event],
                parameterCurves: [curve]
            )

            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)

        } catch {
            print(error)
        }
    }

    // MARK: - UIKit Haptics

    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }

    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    // MARK: - Continuous vibration (CoreHaptics)

    func continuous(duration: Double, intensity: Float = 1, sharpness: Float = 0.2) {
        guard let engine else { return }

        let intensityParam = CHHapticEventParameter(
            parameterID: .hapticIntensity,
            value: intensity
        )

        let sharpnessParam = CHHapticEventParameter(
            parameterID: .hapticSharpness,
            value: sharpness
        )

        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [intensityParam, sharpnessParam],
            relativeTime: 0,
            duration: duration
        )

        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Haptic pattern error:", error)
        }
    }
}
