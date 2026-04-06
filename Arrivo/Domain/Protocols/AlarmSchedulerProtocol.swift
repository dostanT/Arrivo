//
//  AlarmSchedulerProtocol.swift
//  Arrivo
//
import Foundation
protocol AlarmSchedulerProtocol: Sendable {
    func scheduleAlarm(durationSeconds: TimeInterval, label: String) async
}
