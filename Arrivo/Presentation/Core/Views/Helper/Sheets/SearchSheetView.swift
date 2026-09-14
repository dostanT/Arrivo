//
//  SearchSheetView.swift
//  Arrivo
//
//  Created by Dostan Turlybek on 27.02.2026.
//
import SwiftUI

struct SearchSheetView: View {
    @EnvironmentObject private var mapVM: MapViewModel
    @Binding var showSheet: Bool
    @FocusState private var isSearchFocused: Bool
    @Environment(
        \.dismiss
    ) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                ColorConstants.background
                    .ignoresSafeArea()
                List(
                    mapVM.shownStops
                ) { stop in
                    Button {
                        isSearchFocused = false

                        mapVM.toCenter(by: stop.coordinate)
                        mapVM.selectedCoordinate = stop.coordinate

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showSheet = false
                            mapVM.searchText = ""
                        }
                    } label: {
                        Label(
                            stop.name,
                            systemImage: "bus.fill"
                        )
                        .foregroundStyle(ColorConstants.foreground)
                    }
                    .listRowBackground(ColorConstants.background)
                }
                .listStyle(
                    .plain
                )
                .padding(.horizontal)
                .scrollIndicators(.hidden)
                .searchable(
                    text: $mapVM.searchText,
                    placement:
                    .navigationBarDrawer(
                        displayMode: .always
                    )
                )
                .focused(
                    $isSearchFocused
                ) // Привязываем фокус к поиску
                .toolbar(
                    content: {
                        ToolbarItem(
                            placement: .principal
                        ) {
                            Text(
                                mapVM.currentCity.name
                            )
                            .foregroundStyle(
                                ColorConstants.foreground
                            )
                        }
                    }
                )
                .navigationBarTitleDisplayMode(
                    .inline
                )
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationButtonCircleView(imageName: "checkmark") {
                            isSearchFocused = false
                            showSheet = false
                            mapVM.searchText = ""
                            Task {
                                await mapVM.notifySearchSheetDismissTapped()
                            }
                        }
                    }
                }
                .onAppear {
                    // Автоматически показываем клавиатуру при открытии
                    DispatchQueue.main
                        .asyncAfter(
                            deadline:
                            .now() + 0.5
                        ) {
                            isSearchFocused = true
                        }
                }
            }
        }
    }
}
