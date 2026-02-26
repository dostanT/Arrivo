//
//  MapView.swift
//  Arrivo
//
//  Created by Dostan Turlybek on 26.02.2026.
//

import SwiftUI

struct MapView: View {
    @EnvironmentObject private var mapVM: MapViewModel
    @State private var showSheet: Bool = false
    
    var body: some View {
        ZStack {
            MapViewContainer(viewModel: mapVM)
            
            // Кнопка для открытия sheet
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showSheet.toggle()
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                            .padding()
                            .background(ColorConstants.background)
                            .foregroundColor(ColorConstants.foreground)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showSheet) {
            SearchSheetView(showSheet: $showSheet)
        }
    }
}

// Отдельный View для sheet
struct SearchSheetView: View {
    @EnvironmentObject private var mapVM: MapViewModel
    @Binding var showSheet: Bool
    @FocusState private var isSearchFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack{
                ColorConstants.background.ignoresSafeArea()
                List(mapVM.shownStops) { stop in
                    Text(stop.name)
                        .onTapGesture {
                            // Убираем фокус с клавиатуры
                            isSearchFocused = false
                            
                            // Центрируем карту
                            mapVM.toCenter(by: stop.coordinate)
                            mapVM.selectedCoordinate = stop.coordinate
                            
                            // Закрываем sheet с небольшой задержкой
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showSheet = false
                                mapVM.searchText = "" // Очищаем поиск
                            }
                        }
                }
                .searchable(
                    text: $mapVM.searchText,
                    placement: .navigationBarDrawer(
                        displayMode: .always
                    )
                )
                .focused($isSearchFocused) // Привязываем фокус к поиску
                .navigationTitle("Остановки")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Готово") {
                            isSearchFocused = false
                            showSheet = false
                            mapVM.searchText = ""
                        }
                    }
                }
                .onAppear {
                    // Автоматически показываем клавиатуру при открытии
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isSearchFocused = true
                    }
                }
            }
        }
    }
}
