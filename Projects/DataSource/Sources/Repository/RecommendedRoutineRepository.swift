//
//  RecommendedRoutineRepository.swift
//  DataSource
//
//  Created by 최정인 on 7/27/25.
//

import Domain

final class RecommendedRoutineRepository: RecommendedRoutineRepositoryProtocol {
    private let networkService = NetworkService.shared

    func fetchRecommendedRoutines() async throws -> [RecommendedRoutineEntity] {
        let endpoint = RecommendedRoutineEndpoint.fetchRecommendedRoutines
        guard let response = try await networkService.request(endpoint: endpoint, type: RecommendedRoutineDictionaryResponseDTO.self)
        else { return [] }

        var entities: [RecommendedRoutineEntity] = []
        for (category, recommendedRoutines) in response.recommendedRoutines {
            let recommendedRoutineEntity = recommendedRoutines.compactMap({ $0.toRecommendedRoutineEntity(category: category) })
            entities.append(contentsOf: recommendedRoutineEntity)
        }

        return entities
    }
}
