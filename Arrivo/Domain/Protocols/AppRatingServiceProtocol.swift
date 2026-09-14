//
//  AppRatingServiceProtocol.swift
//  Arrivo
//

protocol AppRatingServiceProtocol: Sendable {
    func requestReviewIfAppropriate() async
}
