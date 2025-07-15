//
//  LoginView.swift
//  Presentation
//
//  Created by 최정인 on 6/30/25.
//

import UIKit
import AuthenticationServices
import Combine
import Shared
import SnapKit
import Then

final class LoginView: BaseViewController<LoginViewModel> {

    private enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let logoTopSpacing: CGFloat = 115
        static let logoSize: CGFloat = 335
        static let loginButtonHeight: CGFloat = 54
        static let loginButtonBottomSpacing: CGFloat = 20
        static let loginButtonSpacing: CGFloat = 12
    }

    private let logoView = UIView()
    private let kakaoLoginButton = SocialLoginButton(socialType: .kakao)
    private let appleLoginButton = SocialLoginButton(socialType: .apple)
    private var cancellables: Set<AnyCancellable>

    override init(viewModel: LoginViewModel) {
        cancellables = []
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(navigationStyle: .hidden)
    }

    override func configureAttribute() {
        logoView.do {
            $0.backgroundColor = BitnagilColor.gray90
        }

        kakaoLoginButton.addAction(UIAction { [weak self] _ in
            self?.viewModel.action(input: .kakaoLogin)
        }, for: .touchUpInside)

        appleLoginButton.addAction(UIAction { [weak self] _ in
            self?.appleLogin()
        }, for: .touchUpInside)
    }

    override func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        view.backgroundColor = .systemBackground

        view.addSubview(logoView)
        view.addSubview(kakaoLoginButton)
        view.addSubview(appleLoginButton)

        logoView.snp.makeConstraints { make in
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.trailing.equalTo(safeArea).inset(Layout.horizontalMargin)
            make.top.equalTo(safeArea).offset(Layout.logoTopSpacing)
            make.size.equalTo(Layout.logoSize)
        }

        kakaoLoginButton.snp.makeConstraints { make in
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.trailing.equalTo(safeArea).inset(Layout.horizontalMargin)
            make.bottom.equalTo(appleLoginButton.snp.top).offset(-Layout.loginButtonSpacing)
            make.height.equalTo(Layout.loginButtonHeight)
        }

        appleLoginButton.snp.makeConstraints { make in
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.trailing.equalTo(safeArea).inset(Layout.horizontalMargin)
            make.bottom.equalTo(safeArea).inset(Layout.loginButtonBottomSpacing)
            make.height.equalTo(Layout.loginButtonHeight)
        }
    }

    override func bind() {
        viewModel.output.loginResultPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userState in
                guard let self else { return }
                guard let userState else {
                    // TODO: 로그인 실패 시, 에러 처리
                    BitnagilLogger.log(logType: .error, message: "서버 로그인 실패")
                    return
                }

                BitnagilLogger.log(logType: .info, message: "서버 로그인 성공")
                if userState == .guest {
                    let agreementView = TermsAgreementView(viewModel: self.viewModel)
                    self.navigationController?.pushViewController(agreementView, animated: true)
                } else {
                    guard let onboardingViewModel = DIContainer.shared.resolve(type: OnboardingViewModel.self) else {
                        fatalError("onboardingViewModel 의존성이 등록되지 않았습니다.")
                    }
                    let onboardingView = OnboardingView(viewModel: onboardingViewModel, onboarding: .time)
                    self.navigationController?.pushViewController(onboardingView, animated: true)
                }
            }
            .store(in: &cancellables)
    }

    private func appleLogin() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension LoginView: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard
            let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let authCodeData = credential.authorizationCode,
            let authToken = String(data: authCodeData, encoding: .utf8)
        else {
            BitnagilLogger.log(logType: .error, message: "Apple AuthorizationCode 파싱 실패")
            return
        }

        let givenName = credential.fullName?.givenName
        let familyName = credential.fullName?.familyName

        var nickname: String? = nil
        if let givenName, let familyName {
            nickname = "\(familyName)\(givenName)"
        }
        self.viewModel.action(input: .appleLogin(nickname: nickname, authToken: authToken))
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        BitnagilLogger.log(logType: .error, message: "Apple 로그인 실패")
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension LoginView: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window ?? UIWindow()
    }
}
