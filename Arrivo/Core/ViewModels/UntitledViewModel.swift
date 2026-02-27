//
//  UntitledViewModel.swift
//  Arrivo
//
//  Created by Dostan Turlybek on 26.02.2026.
//
import Combine
import Foundation

@MainActor
final class UntitledViewModel: ObservableObject {
    @Published var launchCount: Int

    @Published var overViewShown: Bool
    @Published var selectedTab: TabEnum = .map

    // MARK: - Init

    init() {
        // Считываем значения из UserDefaults
        let defaults = UserDefaults.standard

        // Счётчик запусков
        launchCount = defaults.integer(forKey: "launchCount")
        overViewShown = defaults.bool(forKey: "overViewShown")

        // Увеличиваем счётчик
        launchCount += 1
        defaults.set(launchCount, forKey: "launchCount")
    }

    func trueOverViewShown() {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "overViewShown")
        overViewShown = true
    }
}
