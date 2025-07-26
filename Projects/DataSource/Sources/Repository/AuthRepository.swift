//
//  AuthRepository.swift
//  DataSource
//
//  Created by 최정인 on 6/30/25.
//

import Foundation
import Domain
import Shared
import KakaoSDKUser
import KakaoSDKAuth

final class AuthRepository: AuthRepositoryProtocol {
    private let networkService = NetworkService.shared
    private let tokenManager = TokenManager.shared
    private let userDefaultsStorage = UserDefaultsStorage.shared

    func kakaoLogin() async throws -> UserEntity {
        let accessToken = try await fetchKakaoToken()
        let user = try await requestServerLogin(
            socialType: .kakao,
            nickname: nil,
            token: accessToken)
        return user
    }

    func appleLogin(nickname: String?, authToken: String) async throws -> UserEntity {
        var savedNickname: String = ""
        if let nickname {
            try saveNickname(nickname: nickname)
            savedNickname = nickname
        } else {
            savedNickname = try loadNickname()
        }
        let user = try await requestServerLogin(
            socialType: .apple,
            nickname: savedNickname,
            token: authToken)
        return user
    }

    func submitAgreement(agreements: [TermsType : Bool]) async throws {
        let endpoint = AuthEndpoint.agreements(agreements: agreements)
        _ = try await networkService.request(endpoint: endpoint, type: EmptyResponseDTO.self)
    }

    func logout() async throws {
        let endpoint = AuthEndpoint.logout
        _ = try await networkService.request(endpoint: endpoint, type: String.self)
        try tokenManager.removeToken()
    }

    func withdraw() async throws {
        let endpoint = AuthEndpoint.withdraw
        _ = try await networkService.request(endpoint: endpoint, type: String.self)
        try tokenManager.removeToken()
        try removeNickname()
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

    private func fetchKakaoToken() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let resultHandler: (OAuthToken?, Error?) -> Void = { oauthToken, error in
                if let error {
                    continuation.resume(throwing: AuthError.unknown(error))
                } else if let oauthToken {
                    continuation.resume(returning: oauthToken.accessToken)
                } else {
                    continuation.resume(throwing: AuthError.kakaoTokenFetchFailed)
                }
            }

            Task { @MainActor in
                if UserApi.isKakaoTalkLoginAvailable() {
                    UserApi.shared.loginWithKakaoTalk(completion: resultHandler)
                } else {
                    UserApi.shared.loginWithKakaoAccount(completion: resultHandler)
                }
            }
        }
    }

    private func requestServerLogin(
        socialType: SocialLoginType,
        nickname: String?,
        token: String
    ) async throws -> UserEntity {
        let endpoint = AuthEndpoint.login(
            socialLoginType: socialType,
            nickname: nickname,
            token: token)

        guard let userResponse = try await networkService.request(endpoint: endpoint, type: LoginResponseDTO.self)
        else { throw AuthError.invalidUserData }

        let userEntity = userResponse.toUserEntity()
        try tokenManager.saveToken(token: userEntity.accessToken, tokenType: .accessToken)
        try tokenManager.saveToken(token: userEntity.refreshToken, tokenType: .refreshToken)

        BitnagilLogger.log(logType: .debug, message: "User Logined: \(userEntity.userState)")
        BitnagilLogger.log(logType: .debug, message: "AccessToken Saved: \(userEntity.accessToken)")
        BitnagilLogger.log(logType: .debug, message: "RefreshToken Saved: \(userEntity.refreshToken)")

        return userEntity
    }

    private func saveNickname(nickname: String) throws {
        guard userDefaultsStorage.save(nickname, forKey: UserDefaultsKey.nickname.rawValue) else {
            throw AuthError.nicknameSaveFailed
        }
    }

    private func loadNickname() throws -> String {
        let nickname: String? = userDefaultsStorage.load(forKey: UserDefaultsKey.nickname.rawValue)
        guard let nickname else {
            throw AuthError.nicknameLoadFailed
        }
        return nickname
    }

    private func removeNickname() throws {
        guard userDefaultsStorage.remove(forKey: UserDefaultsKey.nickname.rawValue) else {
            throw AuthError.nicknameRemoveFailed
        }
    }
}
