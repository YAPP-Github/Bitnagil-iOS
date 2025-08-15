//
//  EmotionRepository.swift
//  DataSource
//
//  Created by 최정인 on 7/28/25.
//

import Domain

final class EmotionRepository: EmotionRepositoryProtocol {
    private let networkService = NetworkService.shared

    /// Fetches the list of emotions from the remote service.
    /// - Returns: An array of `EmotionEntity`. Returns an empty array if the remote response is missing or contains no items.
    /// - Throws: Any error propagated from the network service when the request fails.
    func fetchEmotions() async throws -> [EmotionEntity] {
        let endpoint = EmotionEndpoint.fetchEmotions
        guard let response = try await networkService.request(endpoint: endpoint, type: [EmotionResponseDTO].self)
        else { return [] }

        let emotionEntities = response.compactMap({ $0.toEmotionEntity() })
        return emotionEntities
    }

    /// Loads the emotion recorded for the given date.
    /// - Parameter date: The date string (formatted as expected by the API) for which to load the emotion.
    /// - Returns: A converted `EmotionEntity` for the given date, or `nil` if the response was received but could not be converted to an entity.
    /// - Throws: `NetworkError.unknown` when the network response is nil. Propagates any networking errors thrown by the underlying request.
    func loadEmotion(date: String) async throws -> EmotionEntity? {
        let endpoint = EmotionEndpoint.loadEmotion(date: date)
        guard let response = try await networkService.request(endpoint: endpoint, type: EmotionResponseDTO.self)
        else { throw NetworkError.unknown(description: "Emotion Reponse를 받아오지 못했습니다.") }

        let emotionEntity = response.toEmotionEntity()
        return emotionEntity
    }

    func registerEmotion(emotion: String) async throws -> [RecommendedRoutineEntity] {
        let endpoint = EmotionEndpoint.registerEmotion(emotion: emotion)
        guard let response = try await networkService.request(endpoint: endpoint, type: RecommendedRoutineListResponseDTO.self)
        else { return [] }

        let recommendedRoutineEntity = response.recommendedRoutines.compactMap({ $0.toRecommendedRoutineEntity() })
        return recommendedRoutineEntity
    }
}
