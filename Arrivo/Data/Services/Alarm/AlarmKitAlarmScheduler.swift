//
//  AlarmKitAlarmScheduler.swift
//  Arrivo
//

import Foundation

@available(iOS 26.0, *)
final class AlarmKitAlarmScheduler: AlarmSchedulerProtocol {
    private let alarmService: AlarmService

    init(alarmService: AlarmService) {
        self.alarmService = alarmService
    }

    func scheduleAlarm(durationSeconds: TimeInterval, label: String) async {
        do {
            _ = try await alarmService.scheduleAlarm(with: durationSeconds, label: label)
        } catch {
            print("AlarmKitAlarmScheduler:", error)
        }
    }
}
