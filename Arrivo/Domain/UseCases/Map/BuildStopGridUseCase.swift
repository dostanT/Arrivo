//
//  BuildStopGridUseCase.swift
//  Arrivo
//

protocol BuildStopGridUseCase: Sendable {
    func execute(stops: [Stop]) -> [GridKey: [Stop]]
}

final class BuildStopGridUseCaseImpl: BuildStopGridUseCase {
    func execute(stops: [Stop]) -> [GridKey: [Stop]] {
        GridCalculator.buildGrid(from: stops)
    }
}
