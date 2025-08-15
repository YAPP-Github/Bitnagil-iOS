//
//  EmotionRepository.swift
//  DataSource
//
//  Created by 최정인 on 7/28/25.
//

import Domain

final class EmotionRepository: EmotionRepositoryProtocol {
    private let networkService = NetworkService.shared

    func fetchEmotions() async throws -> [EmotionEntity] {
        let endpoint = EmotionEndpoint.fetchEmotions
        guard let response = try await networkService.request(endpoint: endpoint, type: [EmotionResponseDTO].self)
        else { return [] }

        let emotionEntities = response.compactMap({ $0.toEmotionEntity() })
        return emotionEntities
    }

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
