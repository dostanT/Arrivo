//
//  NotificationAlarmViewModel.swift
//  ArrivoNuvuCollection
//
//  Created by Dostan Turlybek on 22.02.2026.
//

import Combine
import Foundation

@MainActor
final class NotificationAlarmViewModel: ObservableObject, ShudelerProtocol {
    let notificationService = NotificationService()

    func scheduleAlarm(with _: TimeInterval, label: String) async {
        Task {
            await notificationService.scheduleAlarm(label: label)
        }
    }
}
