//
//  UserDataUseCase.swift
//  Domain
//
//  Created by 최정인 on 7/30/25.
//

public final class UserDataUseCase: UserDataUseCaseProtocol {
    private let userDataRepository: UserDataRepositoryProtocol

    public init(userDataRepository: UserDataRepositoryProtocol) {
        self.userDataRepository = userDataRepository
    }

    public func loadNickname() async throws -> String {
        let nickname = try await userDataRepository.loadNickname()
        return nickname
    }
}
