//
//  WithdrawUseCase.swift
//  Domain
//
//  Created by 최정인 on 7/4/25.
//

import Foundation

public final class WithdrawUseCase: WithdrawUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol

    public init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    public func withdraw() async throws {
        try await authRepository.withdraw()
    }
}
