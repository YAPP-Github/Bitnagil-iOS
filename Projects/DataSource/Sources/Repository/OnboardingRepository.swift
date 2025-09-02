//
//  OnboardingRepository.swift
//  DataSource
//
//  Created by 최정인 on 7/15/25.
//

import Domain

final class OnboardingRepository: OnboardingRepositoryProtocol {
    private let networkService = NetworkService.shared
    private let userDefaultsStorage = UserDefaultsStorage.shared

    func loadOnboardingResult() async throws -> OnboardingEntity {
        let endpoint = OnboardingEndpoint.loadOnboardingResult
        guard let response = try await networkService.request(endpoint: endpoint, type: OnboardingResponseDTO.self)
        else { throw UserError.onboardingLoadFailed }

        let onboardingEntity = response.toOnboardingEntity()
        return onboardingEntity
    }

    func registerOnboarding(onboardingEntity: OnboardingEntity) async throws -> [RecommendedRoutineEntity] {
        let onboardingDTO = OnboardingDTO(
            timeSlot: onboardingEntity.time,
            emotionType: onboardingEntity.feeling,
            realOutingFrequency: onboardingEntity.frequency,
            targetOutingFrequency: onboardingEntity.outdoor)
        let endpoint = OnboardingEndpoint.registerOnboarding(onboarding: onboardingDTO)
        guard let response = try await networkService.request(endpoint: endpoint, type: RecommendedRoutineListResponseDTO.self)
        else { return [] }
        
        let recommendedRoutineEntity = response.recommendedRoutines.compactMap({ $0.toRecommendedRoutineEntity() })
        return recommendedRoutineEntity
    }

    func registerRecommendedRoutines(selectedRoutines: [Int]) async throws {
        let endpoint = OnboardingEndpoint.registerRecommendedRoutine(selectedRoutines: selectedRoutines)
        _ = try await networkService.request(endpoint: endpoint, type: EmptyResponseDTO.self)
    }
}
