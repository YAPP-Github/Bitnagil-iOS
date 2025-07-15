//
//  LogoutUseCase.swift
//  Domain
//
//  Created by 최정인 on 7/4/25.
//

import Foundation

public final class LogoutUseCase: LogoutUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol

    public init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    public func logout() async throws {
        try await authRepository.logout()
    }

    public func reissueToken() async throws {
        try await authRepository.reissueToken()
    }
}
