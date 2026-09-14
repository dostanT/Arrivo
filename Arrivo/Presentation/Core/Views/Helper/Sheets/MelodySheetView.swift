//
//  MelodySheetView.swift
//  Arrivo
//
//  Created by Dostan Turlybek on 07.04.2026.
//

import SwiftUI
import MediaPlayer

struct MelodySheetView: View {
    @EnvironmentObject private var vm: MapViewModel
    var body: some View {
        
    }
}


struct MusicPickerView: UIViewControllerRepresentable {
    @Binding var selectedItem: MPMediaItem?

    func makeUIViewController(context: Context) -> MPMediaPickerController {
        let picker = MPMediaPickerController(mediaTypes: .music)
        picker.allowsPickingMultipleItems = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: MPMediaPickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MPMediaPickerControllerDelegate {
        var parent: MusicPickerView
        init(_ parent: MusicPickerView) { self.parent = parent }

        func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
            parent.selectedItem = mediaItemCollection.items.first
            mediaPicker.dismiss(animated: true)
        }

        func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
            mediaPicker.dismiss(animated: true)
        }
    }
}
