//
//  ArrivoApp.swift
//  Arrivo
//
//  Created by Dostan Turlybek on 26.02.2026.
//

import SwiftUI

@main
struct ArrivoApp: App {
    
    @StateObject private var untitledVM: UntitledViewModel
    @StateObject private var mapVM: MapViewModel
    
    init() {
        let IUntitledVM = UntitledViewModel()
        let ILocationVM = LocationViewModel()
        let IMapVM = DependencyContainer.makeMapViewModel(locationService: ILocationVM)
        
        _untitledVM = StateObject(wrappedValue: IUntitledVM)
        _mapVM = StateObject(wrappedValue: IMapVM)
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                Untitled()
            }
            .environmentObject(untitledVM)
            .environmentObject(mapVM)
        }
    }
}
