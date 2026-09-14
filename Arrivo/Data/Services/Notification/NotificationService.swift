//
//  NotificationService.swift
//  ArrivoNuvuCollection
//
//  Created by Dostan Turlybek on 22.02.2026.
//

import UserNotifications

final class NotificationService {
    private let sound: SoundPlaybackProtocol

    init(sound: SoundPlaybackProtocol) {
        self.sound = sound
    }

    func scheduleAlarm(label: String) async {
        let content = UNMutableNotificationContent()
        content.title = label
        content.body = "WAKE UP!!!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "Alarm_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            await sound.playAlarmSound()
        } catch {
            print(error)
        }
    }

    func scheduleNotification(
        title: String,
        subtitle: String,
        hour: Int = 0,
        minute: Int = 0,
        repeats: Bool = false
    ) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = subtitle
        content.sound = .default

//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval, repeats: true)
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: DateComponents(hour: hour, minute: minute),
            repeats: repeats
        )
        let request = UNNotificationRequest(
            identifier: "Notification_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
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

extension NotificationService {
    // MARK: - Отмена всех уведомлений (и будущих, и доставленных)

    func cancelAllNotifications() {
        // 1. Удаляет все запланированные уведомления
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        // 2. Удаляет все уже доставленные из центра уведомлений
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()

        print("✅ Все уведомления отменены")
    }

    // MARK: - Отмена только запланированных (будущих)

    func cancelAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("✅ Все запланированные уведомления отменены")
    }

    // MARK: - Отмена конкретного уведомления по типу

    func cancelAlarms() {
        // Получаем все запланированные уведомления
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let alarmIdentifiers = requests
                .filter { $0.identifier.hasPrefix("Alarm_") }
                .map { $0.identifier }

            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: alarmIdentifiers)
            print("✅ Отменено будильников: \(alarmIdentifiers.count)")
        }
    }

    func cancelNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let notificationIdentifiers = requests
                .filter { $0.identifier.hasPrefix("Notification_") }
                .map { $0.identifier }

            UNUserNotificationCenter.current()
                .removePendingNotificationRequests(withIdentifiers: notificationIdentifiers)
            print("✅ Отменено уведомлений: \(notificationIdentifiers.count)")
        }
    }

    // MARK: - Отмена по конкретному ID

    func cancelNotification(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("✅ Уведомление \(identifier) отменено")
    }

    // MARK: - Очистка только доставленных (из истории)

    func clearDeliveredNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        print("✅ История уведомлений очищена")
    }

    // MARK: - Просмотр всех запланированных (для отладки)

    func printPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("📋 Запланировано уведомлений: \(requests.count)")
            for request in requests {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                   let date = trigger.nextTriggerDate()
                {
                    print("   - \(request.identifier): \(date)")
                }
            }
        }
    }
}
