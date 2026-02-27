//
//  MapViewContainer.swift
//  ArrivoNuvuCollection
//
//  Created by Dostan Turlybek on 20.02.2026.
//

import MapKit
import SwiftUI

struct MapViewContainer: View {
    @ObservedObject var viewModel: MapViewModel

    var body: some View {
        MapReader { proxy in
            Map(position: $viewModel.cameraPosition) {
                if viewModel.isAuthorized {
                    UserAnnotation()
                }

                if let coordinate = viewModel.selectedCoordinate {
                    Annotation("", coordinate: coordinate) {
                        MarkerView(viewModel: viewModel)
                    }

                    MapCircle(center: coordinate, radius: viewModel.radius)
                        .foregroundStyle(Color.gray.opacity(0.3))
                }

                ForEach(viewModel.visibleStops, id: \.id) { stop in
                    Annotation(stop.name, coordinate: stop.coordinate) {
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
                viewModel.handleCameraChange(context)
            }
            .mapStyle(.standard(elevation: .realistic))
            .mapControls {
                MapScaleView()
                MapCompass()
            }
            .onTapGesture { location in
                viewModel.handleMapTap(at: location, proxy: proxy)
            }
        }
    }
}
