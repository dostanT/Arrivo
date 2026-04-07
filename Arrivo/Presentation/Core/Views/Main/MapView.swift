import SwiftUI

struct MapView: View {
    @EnvironmentObject private var mapVM: MapViewModel
    @State private var showSheet = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            MapViewContainer(viewModel: mapVM)

            VStack {
                Spacer()
                
                if mapVM.selectedCoordinate != nil {
                    HStack {
                        Spacer()
                        CircleButton(imageName: "checkmark") {
                            print("Check")
                        }
                    }
                    Slider(value: $mapVM.radius, in: 100 ... 1000, step: 100)
                        .onChange(of: mapVM.radius) { _, _ in
                            mapVM.onRadiusSliderChanged()
                        }
                    StartButton(action: mapVM.startMonitoring)
                }
            }
            .padding(LayoutConstants.Padding.screen)
        }
        .alert("Ready", isPresented: $mapVM.showAlert) {
            Button("OK") { dismiss() }
        } message: {
            Text(mapVM.alertMessage)
        }
        .ifAvailableiOS26OrLower { $0.toolbarBackground(ColorConstants.background, for: .navigationBar) }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(mapVM.currentCity.name)
                    .foregroundStyle(ColorConstants.foreground)
            }

            ToolbarItem(placement: .topBarTrailing) {
                NavigationButtonCircleView(imageName: "location.fill") { mapVM.centerToUserLocation() }
            }

            if !mapVM.startedMonitoringsIDs.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationButtonCircleView(imageName: "bolt.fill") { mapVM.presentStartedMonitoringsSheet() }
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                NavigationButtonCircleView(
                    imageName: mapVM.selectedCoordinate != nil ? "xmark" : "magnifyingglass"
                ) {
                    if mapVM.selectedCoordinate != nil {
                        mapVM.clearSelection()
                    } else {
                        showSheet.toggle()
                    }
                    Task {
                        await mapVM.notifyToolbarSearchTapped()
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSheet) {
            SearchSheetView(showSheet: $showSheet)
        }
    }
}

struct StartButton: View {
    let action: () -> Void

    var body: some View {
        if #available(iOS 26.0, *) {
            Button(action: action) {
                Text("Start")
                    .foregroundStyle(ColorConstants.foreground)
                    .font(.system(size: LayoutConstants.FontSize.title3))
                    .frame(maxWidth: .infinity)
                    .padding(LayoutConstants.Padding.screen)
            }
            .buttonBorderShape(.capsule)
            .buttonStyle(.glass)
        } else {
            Button(action: action) {
                Text("Start")
                    .foregroundStyle(ColorConstants.foreground)
                    .font(.system(size: LayoutConstants.FontSize.title3))
                    .frame(maxWidth: .infinity)
                    .padding(LayoutConstants.Padding.screen)
                    .background(ColorConstants.background)
                    .clipShape(RoundedRectangle(cornerRadius: LayoutConstants.CornerRadius.large))
            }
        }
    }
}

struct CircleButton: View {
    let imageName: String
    let action: () -> Void
    var body: some View {
        if #available(iOS 26.0, *) {
            Button(action: action) {
                Image(systemName: imageName)
                    .foregroundStyle(ColorConstants.foreground)
                    .font(.system(size: LayoutConstants.FontSize.title3))
                    .frame(width: 32, height: 32)
            }
            .buttonBorderShape(.circle)
            .buttonStyle(.glass)
        } else {
            Button(action: action) {
                Image(systemName: imageName)
                    .foregroundStyle(ColorConstants.foreground)
                    .font(.system(size: LayoutConstants.FontSize.title3))
                    .frame(width: 32, height: 32)
                    .background(ColorConstants.background)
                    .clipShape(RoundedRectangle(cornerRadius: LayoutConstants.CornerRadius.large))
            }
        }
    }
}
