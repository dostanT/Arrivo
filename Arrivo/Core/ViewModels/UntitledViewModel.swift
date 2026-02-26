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
    @Published var selectedTab: TabEnum = .map
}
