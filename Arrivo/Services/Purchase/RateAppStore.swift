//
//  RateAppStore.swift
//  Arrivo
//
//  Created by Dostan Turlybek on 10.03.2026.
//

import StoreKit
import UIKit

final class RateService {

    static func request() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        SKStoreReviewController.requestReview(in: scene)
    }
}
