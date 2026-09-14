//
//  UntitledViewModel.swift
//  Arrivo
//

import Combine
import Foundation

@MainActor
final class UntitledViewModel: ObservableObject {
    @Published var launchCount: Int = 0
    @Published var overViewShown: Bool = false
    @Published var selectedTab: TabEnum = .map
    
    
    
    private let appLaunchCoordinator: AppLaunchCoordinatorUseCase
    
    init(appLaunchCoordinator: AppLaunchCoordinatorUseCase) {
        self.appLaunchCoordinator = appLaunchCoordinator
        Task {
            let snapshot = await appLaunchCoordinator.handleLaunch()
            await MainActor.run {
                self.launchCount = snapshot.launchCount
                self.overViewShown = snapshot.overViewShown
            }
        }
      
    }
    
    func trueOverViewShown() {
        appLaunchCoordinator.markOverViewShown()
        overViewShown = true
    }
    
   
}
