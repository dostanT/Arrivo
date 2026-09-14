//
//  NotificationAlarmScheduler.swift
//  Arrivo
//

import Foundation

final class NotificationAlarmScheduler: AlarmSchedulerProtocol {
    private let notificationService: NotificationService

    init(notificationService: NotificationService) {
        self.notificationService = notificationService
    }

    func scheduleAlarm(durationSeconds: TimeInterval, label: String) async {
        await notificationService.scheduleAlarm(label: label)
    }
}
