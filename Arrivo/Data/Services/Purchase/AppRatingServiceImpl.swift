//
//  AppRatingServiceImpl.swift
//  Arrivo
//

import StoreKit
import UIKit

final class AppRatingServiceImpl: AppRatingServiceProtocol {
    init() {}

    func requestReviewIfAppropriate() async {
        await MainActor.run {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
