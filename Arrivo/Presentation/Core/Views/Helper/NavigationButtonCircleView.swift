//
//  NavigationButtonCircleView.swift
//  Arrivo
//
//  Created by Dostan Turlybek on 27.02.2026.
//

import SwiftUI

struct NavigationButtonCircleView: View {
    let imageName: String
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: imageName)
                .font(
                    .system(size: LayoutConstants.Icon.small)
                )
                .foregroundColor(
                    ColorConstants.foreground
                )
        }
    }
}
