//
//  LoginUseCase.swift
//  Domain
//
//  Created by 최정인 on 6/30/25.
//

public final class LoginUseCase: LoginUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol
    private let analyticsLogger: AnalyticsLoggerProtocol

    public init(authRepository: AuthRepositoryProtocol, analyticsLogger: AnalyticsLoggerProtocol) {
        self.authRepository = authRepository
        self.analyticsLogger = analyticsLogger
    }

    public func kakaoLogin() async throws -> UserState {
        let user = try await authRepository.kakaoLogin()
        return user.userState
    }

    public func appleLogin(nickname: String?, authToken: String) async throws -> UserState {
        let user = try await authRepository.appleLogin(nickname: nickname, authToken: authToken)
        return user.userState
    }

    public func sumbitAgreement(agreements: [TermsType: Bool]) async throws {
        try await authRepository.submitAgreement(agreements: agreements)
        analyticsLogger.log(.signUpCompleted)
    }
}
