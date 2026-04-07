//
//  LoadMelodyURLUseCase.swift
//  Arrivo
//
//  Created by Dostan Turlybek on 07.04.2026.
//

import Foundation

protocol LoadMelodyURLUseCase {
    func execute() -> URL?
}

final class LoadMelodyURLUseCaseImpl: LoadMelodyURLUseCase {
    let repository: MelodyURLRepositoryProtocol
    
    init(repository: MelodyURLRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() -> URL? {
        repository.loadMelodyURL()
    }
}
