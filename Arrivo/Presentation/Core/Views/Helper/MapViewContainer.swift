//
//  MapViewContainer.swift
//  ArrivoNuvuCollection
//

import MapKit
import SwiftUI

struct MapViewContainer: View {
    @ObservedObject var viewModel: MapViewModel

    var body: some View {
        MapReader { proxy in
            Map(position: Binding(
                get: { MapCameraPosition.region(viewModel.mapRegion.mkCoordinateRegion) },
                set: { _ in }
            )) {
                if viewModel.isAuthorized {
                    UserAnnotation()
                }

                if let coordinate = viewModel.selectedCoordinate {
                    Annotation("", coordinate: coordinate.clCoordinate) {
                        MarkerView(viewModel: viewModel)
                    }

                    MapCircle(center: coordinate.clCoordinate, radius: viewModel.radius)
                        .foregroundStyle(Color.gray.opacity(0.3))
                }

                ForEach(viewModel.visibleStops, id: \.id) { stop in
                    Annotation(stop.name, coordinate: stop.coordinate.clCoordinate) {
                        Image(systemName: "bus.fill")
                            .font(.system(size: LayoutConstants.Icon.small))
                            .foregroundColor(ColorConstants.foreground)
                            .padding(LayoutConstants.Padding.small)
                            .background(
                                Circle()
                                    .fill(ColorConstants.background)
                                    .shadow(radius: LayoutConstants.Map.Buttons.locationShadowRadius)
                            )
                    }
                }
            }
            .onMapCameraChange(frequency: .onEnd) { context in
                viewModel.onMapRegionChanged(MapRegion(mkRegion: context.region))
            }
            .mapStyle(.standard(elevation: .realistic))
            .mapControls {
                MapScaleView()
                MapCompass()
            }
            .onTapGesture { location in
                guard let coordinate = proxy.convert(location, from: .local) else { return }
                viewModel.selectCoordinate(GeoCoordinate(coordinate))
            }
        }
    }
}
