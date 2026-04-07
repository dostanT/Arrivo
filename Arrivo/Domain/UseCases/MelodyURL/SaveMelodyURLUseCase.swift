
//
//  MelodyUseCase.swift
//  Arrivo
//
//  Created by Dostan Turlybek on 07.04.2026.
//
import Foundation
protocol SaveMelodyURLUseCase {
    func execute(url: URL?)
}

final class SaveMelodyURLUseCaseImpl: SaveMelodyURLUseCase {
    let repository: MelodyURLRepositoryProtocol
    
    init(repository: MelodyURLRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(url: URL?) {
        repository.saveMelodyURL(url: url)
    }
}
