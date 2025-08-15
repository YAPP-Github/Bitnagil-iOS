//
//  EmotionUseCase.swift
//  Domain
//
//  Created by 최정인 on 7/28/25.
//

import Foundation
import Shared

public final class EmotionUseCase: EmotionUseCaseProtocol {
    private let emotionRepository: EmotionRepositoryProtocol

    public init(emotionRepository: EmotionRepositoryProtocol) {
        self.emotionRepository = emotionRepository
    }

    /// Fetches all stored emotion entities.
    /// - Returns: An array of `EmotionEntity` containing all available emotions.
    /// - Throws: Propagates any error thrown by the underlying repository while fetching.
    public func fetchEmotions() async throws -> [EmotionEntity] {
        let emotions = try await emotionRepository.fetchEmotions()
        return emotions
    }

    /// Loads the stored emotion for a specific calendar date.
    /// - Parameters:
    ///   - date: The date to load the emotion for. It is converted to a `yearMonthDate`-formatted string before lookup.
    /// - Returns: The `EmotionEntity` for the given date, or `nil` if none exists.
    /// - Throws: Any error propagated from the underlying repository call.
    public func loadEmotion(date: Date) async throws -> EmotionEntity? {
        let dateString = date.convertToString(dateType: .yearMonthDate)

        let emotion = try await emotionRepository.loadEmotion(date: dateString)
        return emotion
    }
}
