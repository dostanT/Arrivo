//
//  View.swift
//  Arrivo
//
//  Created by Dostan Turlybek on 27.02.2026.
//
import SwiftUI

extension View {
    @ViewBuilder
    func ifAvailableiOS26OrLower<Content: View>(_ modifier: (Self) -> Content) -> some View {
        if #available(iOS 26, *) {
            self
        } else {
            modifier(self)
        }
    }

    @ViewBuilder
    func ifAvailableiOS26OrHigher<Content: View>(_ modifier: (Self) -> Content) -> some View {
        if #available(iOS 26, *) {
            modifier(self)
        } else {
            self
        }
    }
}
