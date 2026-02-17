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

        do {
            guard let response = try await networkService.request(endpoint: endpoint, type: OnboardingResponseDTO.self)
            else { throw UserError.onboardingLoadFailed }

            let onboardingEntity = response.toOnboardingEntity()
            return onboardingEntity
        } catch let error as NetworkError {
            switch error {
            case .needRetry, .invalidURL, .emptyData:
                throw DomainError.requireRetry
            default:
                throw DomainError.business(error.description)
            }
        }
    }

    func registerOnboarding(onboardingEntity: OnboardingEntity) async throws -> [RecommendedRoutineEntity] {
        let onboardingDTO = OnboardingDTO(
            timeSlot: onboardingEntity.time,
            emotionType: onboardingEntity.feeling,
            realOutingFrequency: onboardingEntity.frequency,
            targetOutingFrequency: onboardingEntity.outdoor)
        let endpoint = OnboardingEndpoint.registerOnboarding(onboarding: onboardingDTO)

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

    func registerRecommendedRoutines(selectedRoutines: [Int]) async throws {
        let endpoint = OnboardingEndpoint.registerRecommendedRoutine(selectedRoutines: selectedRoutines)

        do {
            _ = try await networkService.request(endpoint: endpoint, type: EmptyResponseDTO.self)
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
