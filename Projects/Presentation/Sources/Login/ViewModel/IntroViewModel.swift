//
//  IntroViewModel.swift
//  Presentation
//
//  Created by 최정인 on 8/11/25.
//

import Combine
import Domain

public final class IntroViewModel: ViewModel {
    public enum Input {
        case loadNickname
    }

    public struct Output {
        let nicknamePublisher: AnyPublisher<String, Never>
    }

    private(set) var output: Output
    private let nicknameSubject = CurrentValueSubject<String, Never>("")
    private let userDataRepository: UserDataRepositoryProtocol
    init(userDataRepository: UserDataRepositoryProtocol) {
        self.userDataRepository = userDataRepository
        self.output = Output(nicknamePublisher: nicknameSubject.eraseToAnyPublisher())
    }

    public func action(input: Input) {
        switch input {
        case .loadNickname:
            loadNickname()
        }
    }

    private func loadNickname() {
        Task {
            do {
                let nickname = try await userDataRepository.loadNickname()
                nicknameSubject.send(nickname)
            } catch {
                // TODO: 에러처리
            }
        }
    }
}
