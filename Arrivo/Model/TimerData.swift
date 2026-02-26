//
//  TimerData.swift
//  ArrivoNuvuCollection
//
//  Created by Dostan Turlybek on 07.02.2026.
//
import Foundation
import AlarmKit

// MARK: - TimerData (for AlarmKit)
nonisolated struct TimerData: AlarmMetadata {
    let createdAt: Date
    var duration: TimeInterval
    var adjustedRemaining: TimeInterval?
    let label: String?
    
    init(duration: TimeInterval, adjustedRemaining: TimeInterval? = nil, label: String? = nil) {
        self.createdAt = Date()
        self.duration = duration
        self.adjustedRemaining = adjustedRemaining
        self.label = label
    }
}
