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

        do {
            guard let response = try await networkService.request(endpoint: endpoint, type: [EmotionResponseDTO].self)
            else { return [] }

            let emotionEntities = response.compactMap({ $0.toEmotionEntity() })
            return emotionEntities
        } catch let error as NetworkError {
            switch error {
            case .needRetry, .invalidURL, .emptyData:
                throw DomainError.requireRetry
            default:
                throw DomainError.business(error.description)
            }
        } catch {
            throw DomainError.unknown
        }
    }

    func loadEmotion(date: String) async throws -> EmotionEntity? {
        let endpoint = EmotionEndpoint.loadEmotion(date: date)

        do {
            guard let response = try await networkService.request(endpoint: endpoint, type: EmotionResponseDTO.self)
            else { throw NetworkError.unknown(description: "Emotion Reponse를 받아오지 못했습니다.") }

            let emotionEntity = response.toEmotionEntity()
            return emotionEntity
        } catch let error as NetworkError {
            switch error {
            case .needRetry, .invalidURL, .emptyData:
                throw DomainError.requireRetry
            default:
                throw DomainError.business(error.description)
            }
        } catch {
            throw DomainError.unknown
        }
    }

    func registerEmotion(emotion: String) async throws -> [RecommendedRoutineEntity] {
        let endpoint = EmotionEndpoint.registerEmotion(emotion: emotion)

        do {
            guard let response = try await networkService.request(endpoint: endpoint, type: RecommendedRoutineListResponseDTO.self)
            else { return [] }

            let recommendedRoutineEntity = response.recommendedRoutines.compactMap({ $0.toRecommendedRoutineEntity() })
            return recommendedRoutineEntity
        } catch let error as NetworkError {
            switch error {
            case .needRetry, .invalidURL, .emptyData:
                throw DomainError.requireRetry
            default:
                throw DomainError.business(error.description)
            }
        } catch {
            throw DomainError.unknown
        }
    }
}
