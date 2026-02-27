//
//  NotificationService.swift
//  ArrivoNuvuCollection
//
//  Created by Dostan Turlybek on 22.02.2026.
//

import UserNotifications

class NotificationService {
    init() {
        requestNotificationPermission()
    }

    func scheduleAlarm(label: String) async {
        let content = UNMutableNotificationContent()
        content.title = label
        content.body = "WAKE UP!!!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        do {
            try await UNUserNotificationCenter.current().add(request)
            SoundService.shared.play()
        } catch {
            print(error)
        }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Permission Granted")
            } else if let error {
                print(error.localizedDescription)
            } else {
                print("Permission Denied")
            }
        }
    }
}
