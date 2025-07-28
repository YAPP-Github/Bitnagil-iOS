//
//  RecommendedRoutineUseCase.swift
//  Domain
//
//  Created by 최정인 on 7/27/25.
//

public final class RecommendedRoutineUseCase: RecommendedRoutineUseCaseProtocol {
    private let recommendedRoutineRepository: RecommendedRoutineRepositoryProtocol

    public init(recommendedRoutineRepository: RecommendedRoutineRepositoryProtocol) {
        self.recommendedRoutineRepository = recommendedRoutineRepository
    }

    public func fetchRecommendedRoutines() async throws -> [RecommendedRoutineEntity] {
        let recommendedRoutines = try await recommendedRoutineRepository.fetchRecommendedRoutines()
        return recommendedRoutines
    }
}
