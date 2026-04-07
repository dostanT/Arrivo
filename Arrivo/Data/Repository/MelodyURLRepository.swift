//
//  MelodyRepository.swift
//  Arrivo
//
//  Created by Dostan Turlybek on 07.04.2026.
//
import Foundation
final class MelodyURLRepository: MelodyURLRepositoryProtocol {
    private let defaults = UserDefaults.standard
    
    func saveMelodyURL(url: URL?) {
        if let url = url {
            defaults.set(url.absoluteString, forKey: MelodyKey.key)
        } else {
            defaults.removeObject(forKey: MelodyKey.key)
        }
    }
    
    func loadMelodyURL() -> URL? {
        if let urlString = defaults.string(forKey: MelodyKey.key),
           let url = URL(string: urlString) {
            return url
        } else {
            return nil
        }
    }
}


