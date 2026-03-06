//
//  AlarmViewModel.swift
//  ArrivoNuvuCollection
//
//  Created by Dostan Turlybek on 07.02.2026.
//

import AlarmKit
import Combine
import SwiftUI

// MARK: - AlarmViewModel (UI Layer, ObservableObject)

@available(iOS 26.0, *)
@MainActor
final class AlarmViewModel: ObservableObject, ShudelerProtocol {
    // MARK: - Properties

    private let alarmService = AlarmService()

    @Published var alarms: [UUID: Alarm] = [:]
    @Published var alarmModels: [UUID: AlarmModel] = [:]

    var hasScheduledAlarms: Bool {
        !alarms.isEmpty
    }

    // MARK: - Initialization

    init() {
        alarmService.setOnChangeHandler { [weak self] in
            Task { @MainActor in
                self?.updateState()
            }
        }
        updateState()
    }

    // MARK: - Public Methods

    func scheduleAlarm(with duration: TimeInterval, label: String = "") async {
        do {
            _ = try await alarmService.scheduleAlarm(with: duration, label: label)
            updateState()
        } catch {
            print("Error scheduling alarm: \(error)")
        }
    }

    func unscheduleAlarm(with alarmID: UUID) async {
        do {
            try await alarmService.unscheduleAlarm(with: alarmID)
            updateState()
        } catch {
            print("Error unscheduling alarm: \(error)")
        }
    }

    func pause(with alarmID: UUID) async {
        do {
            try await alarmService.pause(with: alarmID)
            updateState()
        } catch {
            print("Error pausing alarm: \(error)")
        }
    }

    func resume(with alarmID: UUID) async {
        do {
            try await alarmService.resume(with: alarmID)
            updateState()
        } catch {
            print("Error resuming alarm: \(error)")
        }
    }

    // MARK: - Private Methods

    private func updateState() {
        alarms = alarmService.getAlarms()
        alarmModels = alarmService.getAlarmModels()
    }
}

// MARK: - FileStorageService remains the same

actor FileStorageService {
    private let fileManager = FileManager.default

    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    func save<T: Codable>(_ object: T, to fileName: String) throws {
        let url = documentsDirectory.appendingPathComponent(fileName)
        let data = try JSONEncoder().encode(object)
        try data.write(to: url)
    }

    func load<T: Codable>(from fileName: String) throws -> T {
        let url = documentsDirectory.appendingPathComponent(fileName)
        guard fileManager.fileExists(atPath: url.path) else {
            throw NSError(domain: "File not found", code: 404)
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
