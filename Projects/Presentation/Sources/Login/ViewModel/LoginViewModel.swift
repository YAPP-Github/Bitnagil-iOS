//
//  LoginViewModel.swift
//  Presentation
//
//  Created by 최정인 on 6/30/25.
//

import Combine
import Domain
import Shared

final class LoginViewModel: ViewModel {
    enum Input {
        case kakaoLogin
        case appleLogin(nickname: String?, authToken: String)
        case toggleAgreement(termsType: TermsType)
        case toggleTotalAgreement
        case submitAgreement
    }

    struct Output {
        let loginResultPublisher: AnyPublisher<UserState?, Never>
        let agreementStatePublisher: AnyPublisher<TermsAgreementState, Never>
        let agreementResultPublisher: AnyPublisher<Bool, Never>
    }

    private(set) var output: Output
    private let loginResultSubject = PassthroughSubject<UserState?, Never>()
    private let agreementStateSubject = CurrentValueSubject<TermsAgreementState, Never>(TermsAgreementState())
    private let agreementResultSubject = PassthroughSubject<Bool, Never>()

    private let loginUseCase: LoginUseCaseProtocol
    private var userInformation: (nickname: String?, token: String)?
    init(loginUseCase: LoginUseCaseProtocol) {
        self.loginUseCase = loginUseCase
        self.output = Output(
            loginResultPublisher: loginResultSubject.eraseToAnyPublisher(),
            agreementStatePublisher: agreementStateSubject.eraseToAnyPublisher(),
            agreementResultPublisher: agreementResultSubject.eraseToAnyPublisher()
        )
    }

    func action(input: Input) {
        switch input {
        case .kakaoLogin:
            Task {
                do {
                    let user = try await loginUseCase.kakaoLogin()
                    loginResultSubject.send(user)
                } catch {
                    BitnagilLogger.log(logType: .error, message: "\(error.localizedDescription)")
                    loginResultSubject.send(nil)
                }
            }

        case .appleLogin(let nickname, let authToken):
            Task {
                do {
                    let user = try await loginUseCase.appleLogin(nickname: nickname, authToken: authToken)
                    loginResultSubject.send(user)
                } catch {
                    BitnagilLogger.log(logType: .error, message: "\(error.localizedDescription)")
                    loginResultSubject.send(nil)
                }
            }

        case .toggleAgreement(let termsType):
            var agreementState = agreementStateSubject.value
            agreementState.toggleState(termType: termsType)
            agreementStateSubject.send(agreementState)

        case .toggleTotalAgreement:
            var agreementState = agreementStateSubject.value
            agreementState.togleAllStates()
            agreementStateSubject.send(agreementState)

        case .submitAgreement:
            Task {
                do {
                    let agreements = agreementStateSubject.value.agreements
                    try await loginUseCase.sumbitAgreement(agreements: agreements)
                    agreementResultSubject.send(true)
                } catch {
                    BitnagilLogger.log(logType: .error, message: "\(error.localizedDescription)")
                    agreementResultSubject.send(false)
                }
            }
        }
    }
}
