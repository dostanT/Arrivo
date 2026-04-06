//
//  DependencyContainer.swift
//  Arrivo
//

import Foundation

enum DependencyContainer {
    private static func makeHapticFeedback() -> HapticFeedbackProtocol {
        HapticFeedbackServiceImpl()
    }

    private static func makeSoundPlayback() -> SoundPlaybackProtocol {
        SoundPlaybackServiceImpl()
    }

    private static func makeKeyValueStorage() -> KeyValueStorageProtocol {
        UserDefaultsKeyValueStorage()
    }

    private static func makePlayHapticUseCase(haptics: HapticFeedbackProtocol) -> PlayHapticFeedbackUseCase {
        PlayHapticFeedbackUseCaseImpl(haptics: haptics)
    }

    private static func makeAlarmScheduler(
        sound: SoundPlaybackProtocol
    ) -> AlarmSchedulerProtocol {
        if #available(iOS 26.0, *) {
            return AlarmKitAlarmScheduler(alarmService: AlarmService())
        }
        let notificationService = NotificationService(sound: sound)
        return NotificationAlarmScheduler(notificationService: notificationService)
    }

    private static func makeLocationCoordination(
        alarmScheduler: AlarmSchedulerProtocol
    ) -> LocationCoordinationUseCase {
        LocationCoordinationUseCaseImpl(
            client: LocationManagerClient(),
            geofenceStore: GeofenceStore(),
            alarmScheduler: alarmScheduler
        )
    }

    static func makeOnboardingViewModel() -> OnboardingViewModel {
        let haptics = makeHapticFeedback()
        let playHaptic = makePlayHapticUseCase(haptics: haptics)
        let sound = makeSoundPlayback()
        let alarm = makeAlarmScheduler(sound: sound)
        let notifications = LocalNotificationSchedulingServiceImpl()
        let location = makeLocationCoordination(alarmScheduler: alarm)
        return OnboardingViewModel(
            locationCoordination: location,
            notifications: notifications,
            alarm: alarm,
            haptics: playHaptic
        )
    }

    static func makeUntitledViewModel() -> UntitledViewModel {
        let storage = makeKeyValueStorage()
        let notifications = LocalNotificationSchedulingServiceImpl()
        let rating = AppRatingServiceImpl()
        let coordinator = AppLaunchCoordinatorUseCaseImpl(
            storage: storage,
            notifications: notifications,
            rating: rating
        )
        return UntitledViewModel(appLaunchCoordinator: coordinator)
    }

    static func makeMapViewModel() -> MapViewModel {
        let storage = makeKeyValueStorage()
        let haptics = makeHapticFeedback()
        let playHaptic = makePlayHapticUseCase(haptics: haptics)
        let sound = makeSoundPlayback()
        let alarmScheduler = makeAlarmScheduler(sound: sound)
        let locationCoordination = makeLocationCoordination(alarmScheduler: alarmScheduler)

        let repository = FileStopsRepository()
        let loadStops = LoadStopsUseCaseImpl(repository: repository)
        let filterStops = FilterVisibleStopsUseCaseImpl()
        let detectCity = DetectCityUseCaseImpl()
        let searchStops = SearchStopsUseCaseImpl()
        let buildGrid = BuildStopGridUseCaseImpl()
        let monitoringPersistence = MonitoringPersistenceUseCaseImpl(storage: storage)
        let findNearest = FindNearestStopUseCaseImpl()

        return MapViewModel(
            locationCoordination: locationCoordination,
            loadStopsUseCase: loadStops,
            filterStopsUseCase: filterStops,
            detectCityUseCase: detectCity,
            searchStopsUseCase: searchStops,
            buildStopGridUseCase: buildGrid,
            playHapticUseCase: playHaptic,
            monitoringPersistence: monitoringPersistence,
            findNearestStopUseCase: findNearest
        )
    }
}
