//
//  ShudelerProtocol.swift
//  ArrivoNuvuCollection
//
//  Created by Dostan Turlybek on 22.02.2026.
//
import Foundation

protocol ShudelerProtocol {
    func scheduleAlarm(with duration: TimeInterval, label: String) async
}

extension ShudelerProtocol {
    func scheduleAlarm(with duration: TimeInterval, label: String = "") async {
        await scheduleAlarm(with: duration, label: label)
    }
}
