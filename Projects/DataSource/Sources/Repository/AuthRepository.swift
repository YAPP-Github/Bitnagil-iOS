//
//  AuthRepository.swift
//  DataSource
//
//  Created by 최정인 on 6/30/25.
//

import Domain
import Foundation
import KakaoSDKAuth
import KakaoSDKUser
import Shared

final class AuthRepository: AuthRepositoryProtocol {
    private let networkService = NetworkService.shared
    private let tokenManager = TokenManager.shared
    private let userDefaultsStorage = UserDefaultsStorage.shared

    // 카카오 로그인을 진행합니다.
    func kakaoLogin() async throws -> UserEntity {
        let accessToken = try await fetchKakaoToken()
        let user = try await requestServerLogin(
            socialType: .kakao,
            nickname: nil,
            token: accessToken)

        try saveSocialLoginType(socialLoginType: .kakao)
        return user
    }

    // 애플 로그인을 진행합니다.
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

        try saveSocialLoginType(socialLoginType: .apple)
        return user
    }

    // 이용 약관 동의를 진행합니다.
    func submitAgreement(agreements: [TermsType : Bool]) async throws {
        let endpoint = AuthEndpoint.agreements(agreements: agreements)
        _ = try await networkService.request(endpoint: endpoint, type: EmptyResponseDTO.self)
    }

    // 로그아웃을 진행합니다.
    func logout() async throws {
        let endpoint = AuthEndpoint.logout
        _ = try await networkService.request(endpoint: endpoint, type: String.self)
        try tokenManager.removeToken()
    }

    // 탈퇴하기를 진행합니다.
    func withdraw() async throws {
        let endpoint = AuthEndpoint.withdraw
        _ = try await networkService.request(endpoint: endpoint, type: String.self)
        try tokenManager.removeToken()
        try removeUserInfo()
    }

    // 카카오 SDK를 통해 카카오 authToken을 받아옵니다.
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

    // 서버 로그인을 진행합니다.
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

    // UserDefaults에 닉네임을 저장합니다.
    private func saveNickname(nickname: String) throws {
        guard userDefaultsStorage.save(nickname, forKey: UserDefaultsKey.nickname.rawValue) else {
            throw UserError.nicknameSaveFailed
        }
    }

    // UserDefaults에 저장된 닉네임을 불러옵니다.
    private func loadNickname() throws -> String {
        let nickname: String? = userDefaultsStorage.load(forKey: UserDefaultsKey.nickname.rawValue)
        guard let nickname else {
            throw UserError.nicknameLoadFailed
        }
        return nickname
    }

    // UserDefaults에 소셜 로그인 타입을 저장합니다.
    private func saveSocialLoginType(socialLoginType: SocialLoginType) throws {
        guard userDefaultsStorage.save(socialLoginType.rawValue, forKey: UserDefaultsKey.socialLoginType.rawValue) else {
            throw UserError.socialLoginTypeSaveFailed
        }
    }

    // UserDefaults에 저장된 유저 정보(닉네임, 소셜 로그인 타입, 프로필 이미지)를 삭제합니다.
    private func removeUserInfo() throws {
        guard userDefaultsStorage.remove(forKey: UserDefaultsKey.nickname.rawValue) else {
            throw UserError.nicknameRemoveFailed
        }

        guard userDefaultsStorage.remove(forKey: UserDefaultsKey.socialLoginType.rawValue) else {
            throw UserError.socialLoginTypeRemoveFailed
        }

        guard userDefaultsStorage.remove(forKey: UserDefaultsKey.onboarding.rawValue) else {
            throw UserError.onboardingRemoveFailed
        }

    }
}
