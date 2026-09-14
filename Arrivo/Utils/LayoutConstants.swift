//
//  LayoutConstants.swift
//  ArrivoNuvuCollection
//
//  Created by Dostan Turlybek on 10.02.2026.
//

import SwiftUI

enum LayoutConstants {
    // MARK: - Отступы и промежутки

    enum Spacing {
        static let zero: CGFloat = 0
        static let extraSmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 20
        static let superLarge: CGFloat = 24
    }

    // MARK: - Размеры для карты

    enum Map {
        static let markerCircleSize: CGFloat = 40
        static let markerPinFontSize: CGFloat = 24
        static let markerOpacity: CGFloat = 0.3

        enum Buttons {
            static let locationIconSize: CGFloat = 22
            static let locationPadding: CGFloat = 12
            static let locationShadowRadius: CGFloat = 2

            static let actionButtonHeight: CGFloat = 56
            static let actionButtonCornerRadius: CGFloat = 16
        }
    }

    // MARK: - Радиусы скругления

    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let BIG: CGFloat = 40
        static let circle: CGFloat = .infinity
    }

    // MARK: - Отступы экрана

    enum Padding {
        static let small: CGFloat = 8
        static let screen: CGFloat = 16
        static let panel: CGFloat = 16
        static let card: CGFloat = 12
        static let circle: CGFloat = 10
    }

    // MARK: - Размеры шрифтов

    enum FontSize {
        static let caption: CGFloat = 12
        static let subheadline: CGFloat = 14
        static let body: CGFloat = 16
        static let title3: CGFloat = 18
        static let title2: CGFloat = 20
        static let title1: CGFloat = 24
        static let BIG: CGFloat = 40
    }

    // MARK: - Размеры иконок

    enum Icon {
        static let small: CGFloat = 16
        static let medium: CGFloat = 20
        static let large: CGFloat = 30
        static let extraLarge: CGFloat = 36
        static let BIG: CGFloat = 60
    }

    // MARK: - Размеры элементов навигации

    enum Navigation {
        static let barHeight: CGFloat = 60
        static let toolbarIconSize: CGFloat = 20
    }
}
