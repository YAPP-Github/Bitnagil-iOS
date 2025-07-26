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

    func loadNickname() throws -> String {
        // TODO: 서버에서 닉넴 보내준대요
        guard let nickname: String = userDefaultsStorage.load(forKey: UserDefaultsKey.nickname.rawValue) else {
            throw UserError.nicknameLoadFailed
        }

        return nickname
    }

    func reissueToken() async -> Bool {
        do {
            let refreshToken = try tokenManager.loadToken(tokenType: .refreshToken)
            let endpoint = AuthEndpoint.reissue(refreshToken: refreshToken)

            guard let tokenResponse = try await networkService.request(endpoint: endpoint, type: TokenResponseDTO.self)
            else { return false }

            try tokenManager.saveToken(token: tokenResponse.accessToken, tokenType: .accessToken)
            try tokenManager.saveToken(token: tokenResponse.refreshToken, tokenType: .refreshToken)

            BitnagilLogger.log(logType: .debug, message: "AccessToken Saved: \(tokenResponse.accessToken)")
            BitnagilLogger.log(logType: .debug, message: "RefreshToken Saved: \(tokenResponse.refreshToken)")

            return true
        } catch {
            BitnagilLogger.log(logType: .error, message: "\(error.localizedDescription)")
            return false
        }
    }
}

