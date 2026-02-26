//
//  ArrivoApp.swift
//  Arrivo
//
//  Created by Dostan Turlybek on 26.02.2026.
//

import SwiftUI

@main
struct ArrivoApp: App {
    
    @StateObject private var untitledVM: UntitledViewModel = .init()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                Untitled()
            }
            .environmentObject(untitledVM)
        }
    }
}
