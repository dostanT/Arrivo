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
            Group {
                if untitledVM.overViewShown {
                    Untitled()
                } else {
                    OnboardingView()
                }
            }
            .environmentObject(untitledVM)
        }
    }
}

/*
 todo
 -Ringtone
 -Tutorial

 -Launch Screen
 -Notification
 -Widget
 -Dynamic Island
 -Report Porblem
 -Support Me
 -
 */

/*
 done
 -Opstimization
 -Kazakhstan + Temirtau
 */
