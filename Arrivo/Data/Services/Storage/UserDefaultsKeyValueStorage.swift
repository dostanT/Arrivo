//
//  UserDefaultsKeyValueStorage.swift
//  Arrivo
//

import Foundation

final class UserDefaultsKeyValueStorage: KeyValueStorageProtocol {
    private let defaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        defaults = userDefaults
    }

    func stringArray(forKey key: String) -> [String]? {
        defaults.stringArray(forKey: key)
    }

    func set(_ value: [String]?, forKey key: String) {
        defaults.set(value, forKey: key)
    }

    func data(forKey key: String) -> Data? {
        defaults.data(forKey: key)
    }

    func set(_ value: Data?, forKey key: String) {
        defaults.set(value, forKey: key)
    }

    func integer(forKey key: String) -> Int {
        defaults.integer(forKey: key)
    }

    func set(_ value: Int, forKey key: String) {
        defaults.set(value, forKey: key)
    }

    func bool(forKey key: String) -> Bool {
        defaults.bool(forKey: key)
    }

    func set(_ value: Bool, forKey key: String) {
        defaults.set(value, forKey: key)
    }

    func double(forKey key: String) -> Double? {
        defaults.object(forKey: key) as? Double
    }

    func set(_ value: Double, forKey key: String) {
        defaults.set(value, forKey: key)
    }
}
