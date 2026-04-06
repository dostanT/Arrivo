//
//  AppLaunchCoordinatorUseCase.swift
//  Arrivo
//

struct LaunchSnapshot: Sendable {
    let launchCount: Int
    let overViewShown: Bool
}

protocol AppLaunchCoordinatorUseCase: Sendable {
    func handleLaunch() async -> LaunchSnapshot
    func markOverViewShown()
}

final class AppLaunchCoordinatorUseCaseImpl: AppLaunchCoordinatorUseCase {
    private let storage: KeyValueStorageProtocol
    private let notifications: LocalNotificationSchedulingProtocol
    private let rating: AppRatingServiceProtocol

    private enum Keys {
        static let launchCount = "launchCount"
        static let overViewShown = "overViewShown"
    }

    init(
        storage: KeyValueStorageProtocol,
        notifications: LocalNotificationSchedulingProtocol,
        rating: AppRatingServiceProtocol
    ) {
        self.storage = storage
        self.notifications = notifications
        self.rating = rating
    }

    func handleLaunch() async -> LaunchSnapshot {
        var count = storage.integer(forKey: Keys.launchCount)
        count += 1
        storage.set(count, forKey: Keys.launchCount)

        let overView = storage.bool(forKey: Keys.overViewShown)

        if overView {
            await scheduleNotificationsIfNeeded(launchCount: count)
            if count % 15 == 0 {
                await rating.requestReviewIfAppropriate()
            }
        }

        return LaunchSnapshot(launchCount: count, overViewShown: overView)
    }

    func markOverViewShown() {
        storage.set(true, forKey: Keys.overViewShown)
    }

    private func scheduleNotificationsIfNeeded(launchCount: Int) async {
        await notifications.cancelAllPending()

        if launchCount > 40 {
            await notifications.scheduleDaily(
                titleKey: "notification.title.goodjob",
                subtitleKey: "notification.subtitle.goodjob",
                hour: 20,
                repeats: true
            )
        } else if launchCount > 30 {
            await notifications.scheduleDaily(
                titleKey: "notification.title.work",
                subtitleKey: "notification.subtitle.work",
                hour: 16,
                repeats: true
            )
        } else if launchCount > 20 {
            await notifications.scheduleDaily(
                titleKey: "notification.title.lunch",
                subtitleKey: "notification.subtitle.lunch",
                hour: 12,
                repeats: true
            )
        } else if launchCount > 10 {
            await notifications.scheduleDaily(
                titleKey: "notification.title.wakeup",
                subtitleKey: "notification.subtitle.wakeup",
                hour: 8,
                repeats: true
            )
        }
    }
}
