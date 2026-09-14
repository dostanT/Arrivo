//
//  MelodyRepositoryProtocol.swift
//  Arrivo
//
//  Created by Dostan Turlybek on 07.04.2026.
//
import Foundation
protocol MelodyURLRepositoryProtocol {
    func saveMelodyURL(url: URL?)
    func loadMelodyURL() -> URL?
}
