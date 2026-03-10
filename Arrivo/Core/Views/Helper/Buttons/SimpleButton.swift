//
//  SimpleButton.swift
//  Arrivo
//
//  Created by Dostan Turlybek on 10.03.2026.
//

import SwiftUI

enum ButtonType {
    case error
    case success
    case warning
    case tap
}

struct SimpleButton<Label: View>: View {
    
    let action: () -> Void
    let type: ButtonType
    let labelView: () -> Label
    
    init(_ buttonType: ButtonType, _ action: @escaping () -> Void,
         @ViewBuilder label: @escaping () -> Label) {
        self.action = action
        self.labelView = label
        self.type = buttonType
    }
    
    var body: some View {
        Button{
            switch type {
            case .error:
                HapticService.shared.notification(.error)
            case .success:
                HapticService.shared.notification(.success)
            case .warning:
                HapticService.shared.notification(.warning)
            case .tap:
                HapticService.shared.impact(.soft)
            }
            action()
        } label: {
            labelView()
        }
    }
}
