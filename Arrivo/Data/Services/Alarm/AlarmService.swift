//
//  AlarmService.swift
//  ArrivoNuvuCollection
//
//  Created by Dostan Turlybek on 07.02.2026.
//

import ActivityKit
import AlarmKit
import Foundation
import SwiftUI

// MARK: - AlarmService (бизнес-логика, без UI)

@available(iOS 26.0, *)
final class AlarmService {
    // MARK: - Type Aliases

    typealias AlarmConfiguration = AlarmManager.AlarmConfiguration<TimerData>

    // MARK: - Properties

    private let alarmManager = AlarmManager.shared
    private let fileStorage = FileStorageService()
    private var alarms: [UUID: Alarm] = [:]
    private var alarmModels: [UUID: AlarmModel] = [:]
    private var onChange: (() -> Void)?

    // MARK: - Initialization

    init() {
        Task {
            await requestAuthorization()
            await loadAlarmModels()
            observeAlarms()
        }
    }

    // MARK: - Public Methods

    func scheduleAlarm(with duration: TimeInterval, label: String = "") async throws -> UUID {
        let id = UUID()
        let attributes = AlarmAttributes(
            presentation: alarmPresentation(with: duration, label: .init(stringLiteral: label)),
            metadata: TimerData(duration: duration, label: label),
            tintColor: .accentColor
        )
        let sound = AlertConfiguration.AlertSound.default
//        let sound = AlertConfiguration.AlertSound.named("lesiakower-chiptune-alarm-clock.mp3")
        let alarmConfiguration = AlarmConfiguration(
            countdownDuration: .init(preAlert: duration, postAlert: nil),
            attributes: attributes,
            sound: sound
        )

        return try await scheduleAlarm(id: id, label: label, alarmConfiguration: alarmConfiguration, duration: duration)
    }

    func scheduleAlarm(
        id: UUID,
        label: String,
        alarmConfiguration: AlarmConfiguration,
        duration: TimeInterval
    ) async throws -> UUID {
        guard await requestAuthorization() else {
            throw AlarmError.notAuthorized
        }

        let alarm = try await alarmManager.schedule(id: id, configuration: alarmConfiguration)

        // Save to memory and file
        let model = AlarmModel(
            id: id,
            createdAt: Date(),
            duration: duration,
            adjustedRemaining: nil,
            label: label
        )

        alarms[id] = alarm
        alarmModels[id] = model
        try await fileStorage.save(alarmModels, to: "alarms.json")

        onChange?()
        print("Added alarm with id: \(id)")
        return id
    }

    func unscheduleAlarm(with alarmID: UUID) async throws {
        try alarmManager.cancel(id: alarmID)

        alarms[alarmID] = nil
        alarmModels[alarmID] = nil
        try await fileStorage.save(alarmModels, to: "alarms.json")

        onChange?()
        print("Removed alarm with id: \(alarmID)")
    }

    func pause(with alarmID: UUID) async throws {
        guard let alarm = alarms[alarmID],
              case .countdown = alarm.state,
              var model = alarmModels[alarmID]
        else {
            throw AlarmError.alarmNotFound
        }

        // Calculate remaining time
        let elapsed = Date().timeIntervalSince(model.createdAt)
        let remaining = max(model.duration - elapsed, 0)
        model.adjustedRemaining = remaining

        // Update model
        alarmModels[alarmID] = model
        try await fileStorage.save(alarmModels, to: "alarms.json")

        // Pause in AlarmKit
        try alarmManager.pause(id: alarmID)
        print("Paused alarm with ID: \(alarmID)")
    }

    func resume(with alarmID: UUID) async throws {
        guard let alarm = alarms[alarmID],
              case .paused = alarm.state,
              var model = alarmModels[alarmID],
              let remaining = model.adjustedRemaining
        else {
            throw AlarmError.alarmNotFound
        }

        // Calculate new start time
        let elapsed = max(model.duration - remaining, 0)
        let newCreatedAt = Date().addingTimeInterval(-elapsed)
        model.createdAt = newCreatedAt
        model.adjustedRemaining = nil

        // Update model
        alarmModels[alarmID] = model
        try await fileStorage.save(alarmModels, to: "alarms.json")

        // Resume in AlarmKit
        try alarmManager.resume(id: alarmID)
        print("Resume alarm with ID: \(alarmID)")
    }

    func getAlarms() -> [UUID: Alarm] {
        return alarms
    }

    func getAlarmModels() -> [UUID: AlarmModel] {
        return alarmModels
    }

    func setOnChangeHandler(_ handler: @escaping () -> Void) {
        onChange = handler
    }

    // MARK: - Private Methods

    private func alarmPresentation(with duration: TimeInterval, label: LocalizedStringResource?) -> AlarmPresentation {
        let alertContent = AlarmPresentation.Alert(title: label ?? "Alarm", stopButton: .stopButton)

        guard duration > 0 else {
            return AlarmPresentation(alert: alertContent)
        }

        let countdownContent = AlarmPresentation.Countdown(title: "Alarm", pauseButton: .pauseButton)
        let pausedContent = AlarmPresentation.Paused(title: "Paused", resumeButton: .resumeButton)

        return AlarmPresentation(alert: alertContent, countdown: countdownContent, paused: pausedContent)
    }

    private func observeAlarms() {
        Task {
            for await incomingAlarms in alarmManager.alarmUpdates {
                await updateAlarmState(with: incomingAlarms)
            }
        }
    }

    private func updateAlarmState(with remoteAlarms: [Alarm]) async {
        // Update existing alarm states
        for updated in remoteAlarms {
            alarms[updated.id] = updated
        }

        let knownAlarmIDs = Set(alarms.keys)
        let incomingAlarmIDs = Set(remoteAlarms.map(\.id))

        // Remove completed alarms
        let removedAlarmsIDs = Set(knownAlarmIDs.subtracting(incomingAlarmIDs))
        for id in removedAlarmsIDs {
            alarms[id] = nil
            alarmModels[id] = nil
        }

        if !removedAlarmsIDs.isEmpty {
            try? await fileStorage.save(alarmModels, to: "alarms.json")
            onChange?()
        }
    }

    private func loadAlarmModels() async {
        do {
            let loaded: [UUID: AlarmModel] = try await fileStorage.load(from: "alarms.json")
            alarmModels = loaded

            // Recreate Alarm objects from models
            for (id, _) in loaded {
                // Note: This is simplified. In production, you might need to recreate
                // Alarm objects from AlarmKit based on the model data
                // For now, we'll just mark them as not directly restorable
                print("Loaded alarm with id: \(id)")
            }

            print("Loaded \(alarmModels.count) alarms from file")
        } catch {
            print("No existing alarms found or error loading: \(error)")
            alarmModels = [:]
        }
    }

    @discardableResult
    private func requestAuthorization() async -> Bool {
        switch alarmManager.authorizationState {
        case .notDetermined:
            do {
                let state = try await alarmManager.requestAuthorization()
                return state == .authorized
            } catch {
                print("Error occurred while requesting authorization: \(error)")
                return false
            }
        case .authorized:
            return true
        case .denied:
            return false
        @unknown default:
            return false
        }
    }
}

// MARK: - AlarmError

enum AlarmError: Error {
    case notAuthorized
    case alarmNotFound
    case schedulingFailed
}

@available(iOS 26.0, *)
extension AlarmButton {
    static var openAppButton: Self {
        AlarmButton(text: "Open", textColor: .white, systemImageName: "timer")
    }

    static var pauseButton: Self {
        AlarmButton(text: "Pause", textColor: .white, systemImageName: "pause.fill")
    }

    static var resumeButton: Self {
        AlarmButton(text: "Resume", textColor: .white, systemImageName: "play.fill")
    }

    static var stopButton: Self {
        AlarmButton(text: "Done", textColor: .white, systemImageName: "stop.fill")
    }
}
