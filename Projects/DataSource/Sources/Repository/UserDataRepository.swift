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

    func reissueToken() async throws {
        let refreshToken = try tokenManager.loadToken(tokenType: .refreshToken)
        let endpoint = AuthEndpoint.reissue(refreshToken: refreshToken)

        guard let userResponse = try await networkService.request(endpoint: endpoint, type: LoginResponseDTO.self)
        else { return }
        let userEntity = userResponse.toUserEntity()

        try tokenManager.saveToken(token: userEntity.accessToken, tokenType: .accessToken)
        try tokenManager.saveToken(token: userEntity.refreshToken, tokenType: .refreshToken)

        BitnagilLogger.log(logType: .debug, message: "User Logined: \(userEntity.userState)")
        BitnagilLogger.log(logType: .debug, message: "AccessToken Saved: \(userEntity.accessToken)")
        BitnagilLogger.log(logType: .debug, message: "RefreshToken Saved: \(userEntity.refreshToken)")
    }
}

