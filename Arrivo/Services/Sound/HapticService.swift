//
//  HapticService.swift
//  ArrivoNuvuCollection
//
//  Created by Dostan Turlybek on 24.02.2026.
//

import UIKit

final class HapticService {
    static let shared = HapticService()

    private init() {}

    // MARK: - Impact

    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    // MARK: - Notification

    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }

    // MARK: - Selection

    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}
