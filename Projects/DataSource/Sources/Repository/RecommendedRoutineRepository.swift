//
//  RecommendedRoutineRepository.swift
//  DataSource
//
//  Created by 최정인 on 7/27/25.
//

import Domain

final class RecommendedRoutineRepository: RecommendedRoutineRepositoryProtocol {
    private let networkService = NetworkService.shared

    func fetchRecommendedRoutine(id: Int) async throws -> RecommendedRoutineEntity? {
        let endpoint = RecommendedRoutineEndpoint.fetchRecommendedRoutine(id: id)

        do {
            guard let recommendedRoutineDTO = try await networkService.request(endpoint: endpoint, type: RecommendedRoutineDTO.self)
            else { return nil }

            return recommendedRoutineDTO.toRecommendedRoutineEntity()
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

    func fetchRecommendedRoutines() async throws -> [RecommendedRoutineEntity] {
        let endpoint = RecommendedRoutineEndpoint.fetchRecommendedRoutines

        do {
            guard let response = try await networkService.request(endpoint: endpoint, type: RecommendedRoutineDictionaryResponseDTO.self)
            else { return [] }

            var entities: [RecommendedRoutineEntity] = []
            for (category, recommendedRoutines) in response.recommendedRoutines {
                let recommendedRoutineEntity = recommendedRoutines.compactMap({ $0.toRecommendedRoutineEntity(category: category) })
                entities.append(contentsOf: recommendedRoutineEntity)
            }

            return entities
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
