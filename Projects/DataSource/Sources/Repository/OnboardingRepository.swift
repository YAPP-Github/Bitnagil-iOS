//
//  OnboardingRepository.swift
//  DataSource
//
//  Created by 최정인 on 7/15/25.
//

import Domain

final class OnboardingRepository: OnboardingRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let keychainStorage: KeychainStorageProtocol

    init(networkService: NetworkServiceProtocol, keychainStorage: KeychainStorageProtocol) {
        self.networkService = networkService
        self.keychainStorage = keychainStorage
    }

    func registerOnboarding(onboardingChoices: [String : String]) async throws -> [RecommendedRoutineEntity] {
        let accessToken = try loadToken(tokenType: .accessToken)
        let endpoint = OnboardingEndpoint.registerOnboarding(accessToken: accessToken, choices: onboardingChoices)

        guard let response = try await networkService.request(endpoint: endpoint, type: RecommendedRoutineListResponseDTO.self)
        else { return [] }

        let recommendedRoutineEntity = response.recommendedRoutines.compactMap({ $0.toRecommendedRoutineEntity() })
        return recommendedRoutineEntity
    }

    func registerRecommendedRoutines(selectedRoutines: [Int]) async throws {
        let accessToken = try loadToken(tokenType: .accessToken)
        let endpoint = OnboardingEndpoint.registerRecommendedRoutine(accessToken: accessToken, selectedRoutines: selectedRoutines)
        _ = try await networkService.request(endpoint: endpoint, type: EmptyResponseDTO.self)
    }

    private func loadToken(tokenType: TokenType) throws -> String {
        guard let token = keychainStorage.load(forKey: tokenType.rawValue) else {
            throw AuthError.tokenLoadFailed
        }
        return token
    }
}
