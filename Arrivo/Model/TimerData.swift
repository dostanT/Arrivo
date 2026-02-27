//
//  TimerData.swift
//  ArrivoNuvuCollection
//
//  Created by Dostan Turlybek on 07.02.2026.
//
import AlarmKit
import Foundation

// MARK: - TimerData (for AlarmKit)

nonisolated struct TimerData: AlarmMetadata {
    let createdAt: Date
    var duration: TimeInterval
    var adjustedRemaining: TimeInterval?
    let label: String?

    init(duration: TimeInterval, adjustedRemaining: TimeInterval? = nil, label: String? = nil) {
        createdAt = Date()
        self.duration = duration
        self.adjustedRemaining = adjustedRemaining
        self.label = label
    }
}
