//
//  OnboardingUseCase.swift
//  Domain
//
//  Created by 최정인 on 7/15/25.
//

import Foundation

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

    private func convertToDictionary(onboardingChoices: [OnboardingChoiceType]) -> [String: String] {
        guard
            let timeSlot = onboardingChoices.filter({ $0.onboardingType == .time }).first,
            let frequency = onboardingChoices.filter({ $0.onboardingType == .frequency }).first,
            let emotion = onboardingChoices.filter({ $0.onboardingType == .feeling }).first,
            let outdoor = onboardingChoices.filter({ $0.onboardingType == .outdoor }).first
        else { return [:] }

        var result: [String: String] = [:]
        let choices = [timeSlot, frequency, emotion, outdoor]
        for choice in choices {
            result[choice.onboardingType.key] = choice.value
        }
        return result
    }

    private func convertTo() {
    }
}
