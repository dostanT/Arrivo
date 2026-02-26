//
//  AlarmModel.swift
//  ArrivoNuvuCollection
//
//  Created by Dostan Turlybek on 07.02.2026.
//

import Foundation

struct AlarmModel: Identifiable, Codable {
    let id: UUID
    var createdAt: Date
    var duration: TimeInterval
    var adjustedRemaining: TimeInterval?
    var label: String?
    
    init(id: UUID = UUID(), createdAt: Date, duration: TimeInterval, adjustedRemaining: TimeInterval? = nil, label: String? = nil) {
        self.id = id
        self.createdAt = createdAt
        self.duration = duration
        self.adjustedRemaining = adjustedRemaining
        self.label = label
    }
}
