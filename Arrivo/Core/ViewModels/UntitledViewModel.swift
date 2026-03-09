//
//  UntitledViewModel.swift
//  Arrivo
//
//  Created by Dostan Turlybek on 26.02.2026.
//
import Combine
import Foundation

@MainActor
final class UntitledViewModel: ObservableObject {
    @Published var launchCount: Int

    @Published var overViewShown: Bool
    @Published var selectedTab: TabEnum = .map

    var notificationService: NotificationService?

    // MARK: - Init

    init() {
        // Считываем значения из UserDefaults
        let defaults = UserDefaults.standard

        // Счётчик запусков
        launchCount = defaults.integer(forKey: "launchCount")
        overViewShown = defaults.bool(forKey: "overViewShown")

        // Увеличиваем счётчик
        launchCount += 1
        defaults.set(launchCount, forKey: "launchCount")

        Task {
            await scheduleNotification()
        }
    }

    func trueOverViewShown() {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "overViewShown")
        overViewShown = true
    }
}

extension UntitledViewModel {
    func scheduleNotification() async {
        notificationService = .init()
        notificationService?.cancelNotifications()

        if launchCount > 10 {
            await notificationService?
                .scheduleNotification(
                    title: String(localized: "notification.title.wakeup"),
                    subtitle: String(localized: "notification.subtitle.wakeup"),
                    hour: 8,
                    repeats: true
                )
        } else if launchCount > 20 {
            await notificationService?
                .scheduleNotification(
                    title: String(localized: "notification.title.lunch"),
                    subtitle: String(localized: "notification.subtitle.lunch"),
                    hour: 12,
                    repeats: true
                )
        } else if launchCount > 30 {
            await notificationService?
                .scheduleNotification(
                    title: String(localized: "notification.title.work"),
                    subtitle: String(localized: "notification.subtitle.work"),
                    hour: 16,
                    repeats: true
                )
        } else if launchCount > 40 {
            await notificationService?
                .scheduleNotification(
                    title: String(localized: "notification.title.goodjob"),
                    subtitle: String(localized: "notification.subtitle.goodjob"),
                    hour: 20,
                    repeats: true
                )
        }
        notificationService = nil
    }
}
