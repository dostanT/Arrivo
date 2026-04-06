//
//  KeyValueStorageProtocol.swift
//  Arrivo
//

import Foundation

protocol KeyValueStorageProtocol: Sendable {
    func stringArray(forKey key: String) -> [String]?
    func set(_ value: [String]?, forKey key: String)
    func data(forKey key: String) -> Data?
    func set(_ value: Data?, forKey key: String)
    func integer(forKey key: String) -> Int
    func set(_ value: Int, forKey key: String)
    func bool(forKey key: String) -> Bool
    func set(_ value: Bool, forKey key: String)
    func double(forKey key: String) -> Double?
    func set(_ value: Double, forKey key: String)
}
