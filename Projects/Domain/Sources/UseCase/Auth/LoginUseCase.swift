//
//  LoginUseCase.swift
//  Domain
//
//  Created by 최정인 on 6/30/25.
//

import Foundation

public final class LoginUseCase: LoginUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol

    public init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    public func kakaoLogin() async throws {
        try await authRepository.kakaoLogin()
    }

    public func appleLogin(nickname: String?, authToken: String) async throws {
        try await authRepository.appleLogin(nickname: nickname, authToken: authToken)
    }

    public func sumbitAgreement(agreements: [TermsType: Bool]) async throws {
        try await authRepository.submitAgreement(agreements: agreements)
    }
}
