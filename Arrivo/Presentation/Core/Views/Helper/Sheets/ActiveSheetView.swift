//
//  ActiveSheetView.swift
//  Arrivo
//
//  Created by Dostan Turlybek on 28.02.2026.
//

import SwiftUI

struct ActiveSheetView: View {
    @EnvironmentObject private var mapVM: MapViewModel
    @State private var stopNames: [String: String] = [:]

    var body: some View {
        NavigationStack {
            ZStack {
                ColorConstants.background
                    .ignoresSafeArea()

                List {
                    ForEach(mapVM.startedMonitoringsIDs, id: \.self) { id in
                        Label(
                            stopNames[id] ?? "Loading…",
                            systemImage: "bus.fill"
                        )
                        .foregroundStyle(ColorConstants.foreground)
                        .listRowBackground(ColorConstants.background)
                        .onAppear {
                            loadStopNameIfNeeded(for: id)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                mapVM.stopMonitoring(id: id)
                            } label: {
                                Label("Stop", systemImage: "stop.fill")
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
            let id = mapVM.startedMonitoringsIDs[index]
            mapVM.stopMonitoring(id: id)
        }
    }

    private func loadStopNameIfNeeded(for id: String) {
        guard stopNames[id] == nil else { return }

        Task {
            if let stop = await mapVM.getNearestStopInformation(id: id) {
                await MainActor.run {
                    stopNames[id] = stop.name
                }
            }
        }
    }
}
