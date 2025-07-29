//
//  EmotionUseCase.swift
//  Domain
//
//  Created by 최정인 on 7/28/25.
//

public final class EmotionUseCase: EmotionUseCaseProtocol {
    private let emotionRepository: EmotionRepositoryProtocol

    public init(emotionRepository: EmotionRepositoryProtocol) {
        self.emotionRepository = emotionRepository
    }

    public func fetchEmotions() async throws -> [EmotionEntity] {
        let emotions = try await emotionRepository.fetchEmotions()
        return emotions
    }
}
