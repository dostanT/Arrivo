//
//  PlayHapticFeedbackUseCase.swift
//  Arrivo
//

protocol PlayHapticFeedbackUseCase: Sendable {
    func execute(_ kind: HapticFeedbackKind) async
}

final class PlayHapticFeedbackUseCaseImpl: PlayHapticFeedbackUseCase {
    private let haptics: HapticFeedbackProtocol

    init(haptics: HapticFeedbackProtocol) {
        self.haptics = haptics
    }

    func execute(_ kind: HapticFeedbackKind) async {
        await haptics.play(kind)
    }
}
