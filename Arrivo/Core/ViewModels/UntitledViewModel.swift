//
//  UntitledViewModel.swift
//  Arrivo
//
//  Created by Dostan Turlybek on 26.02.2026.
//
import Foundation
import Combine


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
        self.launchCount = defaults.integer(forKey: "launchCount")
        self.overViewShown = defaults.bool(forKey: "overViewShown")
        
        // Увеличиваем счётчик
        self.launchCount += 1
        defaults.set(self.launchCount, forKey: "launchCount")
    }
    
    func trueOverViewShown() {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "overViewShown")
        overViewShown = true
    }
}
