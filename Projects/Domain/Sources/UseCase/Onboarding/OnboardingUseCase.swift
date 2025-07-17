//
//  OnboardingUseCase.swift
//  Domain
//
//  Created by 최정인 on 7/15/25.
//

public final class OnboardingUseCase: OnboardingUseCaseProtocol {
    private let onboardingRepository: OnboardingRepositoryProtocol

    public init(onboardingRepository: OnboardingRepositoryProtocol) {
        self.onboardingRepository = onboardingRepository
    }

    public func registerOnboarding(onboardingChoices: [OnboardingChoiceType]) async throws -> [RecommendedRoutineEntity] {
        let choices = convertToDictionary(onboardingChoices: onboardingChoices)
        let recommendedRoutines = try await onboardingRepository.registerOnboarding(onboardingChoices: choices)
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
