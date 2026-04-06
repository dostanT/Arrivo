//
//  OnboardingViewModel.swift
//  Arrivo
//

import Combine
import Foundation

@MainActor
final class OnboardingViewModel: ObservableObject {
    private let locationCoordination: LocationCoordinationUseCase
    private let notifications: LocalNotificationSchedulingProtocol
    private let alarm: AlarmSchedulerProtocol
    private let haptics: PlayHapticFeedbackUseCase

    init(
        locationCoordination: LocationCoordinationUseCase,
        notifications: LocalNotificationSchedulingProtocol,
        alarm: AlarmSchedulerProtocol,
        haptics: PlayHapticFeedbackUseCase
    ) {
        self.locationCoordination = locationCoordination
        self.notifications = notifications
        self.alarm = alarm
        self.haptics = haptics
    }

    func playWaveHaptic(duration: Double) async {
        await haptics.execute(.wave(durationSeconds: duration))
    }

    func requestAllPermissions() {
        locationCoordination.requestWhenInUseAuthorization()
        Task {
            await notifications.requestAuthorizationIfNeeded()
        }
        if #available(iOS 26.0, *) {
            Task {
                await alarm.scheduleAlarm(durationSeconds: 1, label: "onboarding")
            }
        }
    }

    func requestLightImpact() async {
        await haptics.execute(.lightImpact)
    }

    func requestSoftImpact() async {
        await haptics.execute(.softImpact)
    }
}
