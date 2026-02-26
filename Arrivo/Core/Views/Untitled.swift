
//
//  Untitled.swift
//  Arrivo
//
//  Created by Dostan Turlybek on 26.02.2026.
//

import SwiftUI

struct Untitled: View {
    
    @EnvironmentObject private var untitledVM: UntitledViewModel
    
    var body: some View {
        
        TabView(selection: $untitledVM.selectedTab) {
            ProfileView()
                .tag(TabEnum.profile)
                .tabItem {
                    Label(TabEnum.profile.displayName,
                          systemImage: untitledVM.selectedTab == .profile ?
                          TabEnum.profile.selectedIconName : TabEnum.profile.iconName)
                }
                .toolbarBackground(ColorConstants.background, for: .tabBar)
            
            MapView()
                .tag(TabEnum.map)
                .tabItem {
                    Label(TabEnum.map.displayName,
                          systemImage: untitledVM.selectedTab == .map ?
                          TabEnum.map.selectedIconName : TabEnum.map.iconName)
                }
                .toolbarBackground(ColorConstants.background, for: .tabBar)
            
            SettingsView()
                .tag(TabEnum.settings)
                .tabItem {
                    Label(TabEnum.settings.displayName,
                          systemImage: untitledVM.selectedTab == .settings ?
                          TabEnum.settings.selectedIconName : TabEnum.settings.iconName)
                }
                .toolbarBackground(ColorConstants.background, for: .tabBar)
        }
        .accentColor(ColorConstants.foreground)
        .toolbarBackground(ColorConstants.background, for: .navigationBar)
    }
}
