//
//  LocalNotificationSchedulingProtocol.swift
//  Arrivo
//

protocol LocalNotificationSchedulingProtocol: Sendable {
    func requestAuthorizationIfNeeded() async
    func cancelAllPending() async
    /// Localization keys for string catalogs.
    func scheduleDaily(
        titleKey: String,
        subtitleKey: String,
        hour: Int,
        repeats: Bool
    ) async
}
