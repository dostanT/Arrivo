//
//  LocalNotificationSchedulingServiceImpl.swift
//  Arrivo
//

import UserNotifications

final class LocalNotificationSchedulingServiceImpl: LocalNotificationSchedulingProtocol {
    init() {}

    func requestAuthorizationIfNeeded() async {
        await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
                continuation.resume()
            }
        }
    }

    func cancelAllPending() async {
        await MainActor.run {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
    }

    func scheduleDaily(titleKey: String, subtitleKey: String, hour: Int, repeats: Bool) async {
        let title = String(localized: String.LocalizationValue(titleKey))
        let subtitle = String(localized: String.LocalizationValue(subtitleKey))
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = subtitle
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: DateComponents(hour: hour, minute: 0),
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
}
