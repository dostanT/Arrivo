//
//  MarkerView.swift
//  ArrivoNuvuCollection
//
//  Created by Dostan Turlybek on 20.02.2026.
//
import SwiftUI

struct MarkerView: View {
    @ObservedObject var viewModel: MapViewModel
    var body: some View{
        ZStack {
            Circle()
                .fill(Color.red.opacity(LayoutConstants.Map.markerOpacity))
                .frame(
                    width: LayoutConstants.Map.markerCircleSize,
                    height: LayoutConstants.Map.markerCircleSize
                )
                .scaleEffect(viewModel.markerScale)
                .opacity(viewModel.markerOpacity)
            
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: LayoutConstants.Map.markerPinFontSize))
                .foregroundColor(.red)
                .background(Color.white)
                .clipShape(Circle())
                .scaleEffect(viewModel.markerScale)
        }
    }
}
