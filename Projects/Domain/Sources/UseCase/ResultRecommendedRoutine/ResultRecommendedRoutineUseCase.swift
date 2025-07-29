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

    public func fetchResultRecommendedRoutines(onboardingChoices: [OnboardingChoiceType]) async throws -> [RecommendedRoutineEntity] {
        let choices = convertToDictionary(onboardingChoices: onboardingChoices)
        let recommendedRoutines = try await onboardingRepository.registerOnboarding(onboardingChoices: choices)
        return recommendedRoutines
    }

    public func fetchResultRecommendedRoutines(emotion: String) async throws -> [RecommendedRoutineEntity] {
        let recommendedRoutines = try await emotionRepository.registerEmotion(emotion: emotion)
        return recommendedRoutines
    }

    public func registerRecommendedRoutines(selectedRoutines: [Int]) async throws {
        try await onboardingRepository.registerRecommendedRoutines(selectedRoutines: selectedRoutines)
    }

    private func convertToDictionary(onboardingChoices: [OnboardingChoiceType]) -> [String: String] {
        var result: [String: String] = [:]
        let onboardingTypes: [OnboardingType] = [.time, .frequency, .feeling, .outdoor]
        for type in onboardingTypes {
            guard let choice = onboardingChoices.first(where: { $0.onboardingType == type })
            else { break }
            result[choice.onboardingType.key] = choice.value
        }
        return result
    }
}
