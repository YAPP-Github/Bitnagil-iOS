//
//  ResultRecommendedRoutineUseCase.swift
//  Domain
//
//  Created by 최정인 on 7/29/25.
//


public final class ResultRecommendedRoutineUseCase: ResultRecommendedRoutineUseCaseProtocol {
    private let onboardingRepository: OnboardingRepositoryProtocol
    private let emotionRepository: EmotionRepositoryProtocol

    public init(onboardingRepository: OnboardingRepositoryProtocol, emotionRepository: EmotionRepositoryProtocol) {
        self.onboardingRepository = onboardingRepository
        self.emotionRepository = emotionRepository
    }

    public func fetchResultRecommendedRoutines(onboardingEntity: OnboardingEntity) async throws -> [RecommendedRoutineEntity] {
        let recommendedRoutines = try await onboardingRepository.registerOnboarding(onboardingEntity: onboardingEntity)
        return recommendedRoutines
    }

    public func fetchResultRecommendedRoutines(emotion: String) async throws -> [RecommendedRoutineEntity] {
        let recommendedRoutines = try await emotionRepository.registerEmotion(emotion: emotion)
        return recommendedRoutines
    }

    public func registerRecommendedRoutines(selectedRoutines: [Int]) async throws {
        try await onboardingRepository.registerRecommendedRoutines(selectedRoutines: selectedRoutines)
    }
}
