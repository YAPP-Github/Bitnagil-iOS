//
//  UserDataRepository.swift
//  DataSource
//
//  Created by 이동현 on 7/20/25.
//

import Domain
import Foundation
import Shared

final class UserDataRepository: UserDataRepositoryProtocol {
    private let networkService = NetworkService.shared
    private let userDefaultsStorage = UserDefaultsStorage.shared
    private let tokenManager = TokenManager.shared

    func loadNickname() async throws -> String {
        let endpoint = UserEndpoint.loadNickname
        guard let user = try await networkService.request(endpoint: endpoint, type: UserDataResponseDTO.self)
        else { return "" }

        return user.nickname
    }

    func reissueToken() async -> UserState? {
        do {
            let refreshToken = try tokenManager.loadToken(tokenType: .refreshToken)
            let endpoint = AuthEndpoint.reissue(refreshToken: refreshToken)

            guard let loginResponse = try await networkService.request(endpoint: endpoint, type: LoginResponseDTO.self)
            else { return nil }

            try tokenManager.saveToken(token: loginResponse.accessToken, tokenType: .accessToken)
            try tokenManager.saveToken(token: loginResponse.refreshToken, tokenType: .refreshToken)

            BitnagilLogger.log(logType: .debug, message: "AccessToken Saved: \(loginResponse.accessToken)")
            BitnagilLogger.log(logType: .debug, message: "RefreshToken Saved: \(loginResponse.refreshToken)")
            BitnagilLogger.log(logType: .debug, message: "User State: \(loginResponse.userState)")

            let userState = UserState(rawValue: loginResponse.userState)
            return userState
        } catch {
            BitnagilLogger.log(logType: .error, message: "\(error.localizedDescription)")
            return nil
        }
    }
}

