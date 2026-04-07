//
//  ArrivoApp.swift
//  Arrivo
//
//  Created by Dostan Turlybek on 26.02.2026.
//

import SwiftUI

@main
struct ArrivoApp: App {
    @StateObject private var untitledVM = DependencyContainer.makeUntitledViewModel()
    @StateObject private var onboardingVM = DependencyContainer.makeOnboardingViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if untitledVM.overViewShown {
                    Untitled()
                } else {
                    OnboardingView(onboardingViewModel: onboardingVM)
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
 -Widget
 -Dynamic Island
 -Report Porblem
 -Support Me
 -AppIcon(Ring at the topTrailing)
 */

/*
 done
 -Opstimization
 -Kazakhstan + Temirtau
 -Notification
 -Haptics
 -Rate(AppStore)
 */

/*
 
 города которые мы основали
 с какого вы города?
 
 */

/*
 когда отмечаю место я будут кнопки о репорте
 */

/*
 developer page добавить в приложение
 */
