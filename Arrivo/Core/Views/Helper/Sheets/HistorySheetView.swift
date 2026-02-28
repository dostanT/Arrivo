//
//  HistorySheetView.swift
//  Arrivo
//
//  Created by Dostan Turlybek on 28.02.2026.
//

import CoreLocation
import SwiftUI

struct HistorySheetView: View {
    @EnvironmentObject private var mapVM: MapViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                ColorConstants.background
                    .ignoresSafeArea()

                List {
                    ForEach(mapVM.oldMonitoringsCoordinate) { coordinate in
                        Label(
                            coordinate.text,
                            systemImage: "bus.fill"
                        )
                        .foregroundStyle(ColorConstants.foreground)
                        .listRowBackground(ColorConstants.background)
                        .swipeActions {
                            Button(role: .destructive) {
                                mapVM.oldMonitoringsCoordinate.removeAll(where: { $0.id == coordinate.id })
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                        }
                    }
                    .onDelete(perform: deleteMonitoring)
                }
                .listStyle(.plain)
                .padding(.horizontal)
                .scrollIndicators(.hidden)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Active monitorings")
                            .foregroundStyle(ColorConstants.foreground)
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        EditButton()
                    }
                }
            }
        }
    }

    private func deleteMonitoring(at offsets: IndexSet) {
        for index in offsets {
            let coordinate = mapVM.oldMonitoringsCoordinate[index]
            mapVM.oldMonitoringsCoordinate.removeAll(where: { $0.id == coordinate.id })
        }
    }
}
