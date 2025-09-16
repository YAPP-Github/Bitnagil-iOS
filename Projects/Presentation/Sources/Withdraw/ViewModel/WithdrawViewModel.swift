//
//  WithdrawViewModel.swift
//  Presentation
//
//  Created by 최정인 on 9/4/25.
//

import Combine
import Domain

final class WithdrawViewModel: ViewModel {
    enum Input {
        case toggleConfirmButton
        case choiceWithdrawReason(reason: WithdrawReason?)
        case inputWithdrawReason(reason: String)
        case withdrawService
    }

    struct Output {
        let confirmPublisher: AnyPublisher<Bool, Never>
        let withdrawReasonPublisher: AnyPublisher<WithdrawReason?, Never>
        let withdrawButtonPublisher: AnyPublisher<Bool, Never>
        let withdrawResultPublisher: AnyPublisher<Bool, Never>
    }

    private(set) var output: Output
    private let confirmSubject = CurrentValueSubject<Bool, Never>(false)
    private let withdrawReasonSubject = CurrentValueSubject<WithdrawReason?, Never>(nil)
    private var withdrawReasonText: String = ""
    private let withdrawButtonSubject = PassthroughSubject<Bool, Never>()
    private let withdrawResultSubject = PassthroughSubject<Bool, Never>()

    private let authRepository: AuthRepositoryProtocol
    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
        self.output = Output(
            confirmPublisher: confirmSubject.eraseToAnyPublisher(),
            withdrawReasonPublisher: withdrawReasonSubject.eraseToAnyPublisher(),
            withdrawButtonPublisher: withdrawButtonSubject.eraseToAnyPublisher(),
            withdrawResultPublisher: withdrawResultSubject.eraseToAnyPublisher())
    }

    func action(input: Input) {
        switch input {
        case .toggleConfirmButton:
            let confirmValue = !confirmSubject.value
            confirmSubject.send(confirmValue)

        case .choiceWithdrawReason(let reason):
            choiceWithdrawReason(reason: reason)

        case .inputWithdrawReason(let reason):
            inputWithdrawReason(reason: reason)

        case .withdrawService:
            withdraw()
        }
    }

    private func choiceWithdrawReason(reason: WithdrawReason?) {
        let currentSelectedReason = withdrawReasonSubject.value
        withdrawReasonSubject.send(nil)
        withdrawReasonText = ""
        if reason != currentSelectedReason {
            withdrawReasonSubject.send(reason)
        }
        updateWithdrawButtonState()
    }

    private func inputWithdrawReason(reason: String) {
        withdrawReasonText = reason
        updateWithdrawButtonState()
    }

    private func updateWithdrawButtonState() {
        let canWithdraw = withdrawReasonSubject.value != nil || !withdrawReasonText.isEmpty
        withdrawButtonSubject.send(canWithdraw)
    }

    private func withdraw() {
        Task {
            do {
                let withdrawReason = withdrawReasonSubject.value?.title ?? withdrawReasonText
                try await authRepository.withdraw(reason: withdrawReason)
                withdrawResultSubject.send(true)
            } catch {
                withdrawResultSubject.send(false)
            }
        }
    }
}
