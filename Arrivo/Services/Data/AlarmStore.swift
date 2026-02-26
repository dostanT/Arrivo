//
//  AlarmStore.swift
//  ArrivoNuvuCollection
//
//  Created by Dostan Turlybek on 07.02.2026.
//
import Foundation

final class AlarmStore {

    static let shared = AlarmStore()

    private let fileURL: URL

    private init() {
        let dir = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!

        fileURL = dir.appendingPathComponent("alarms.json")
    }

    func load() -> [UUID: AlarmModel] {
        guard
            let data = try? Data(contentsOf: fileURL),
            let decoded = try? JSONDecoder().decode([UUID: AlarmModel].self, from: data)
        else {
            return [:]
        }
        return decoded
    }

    func save(_ alarms: [UUID: AlarmModel]) {
        guard let data = try? JSONEncoder().encode(alarms) else { return }
        try? data.write(to: fileURL, options: [.atomic])
    }

    func remove(id: UUID) {
        var alarms = load()
        alarms[id] = nil
        save(alarms)
    }
}
