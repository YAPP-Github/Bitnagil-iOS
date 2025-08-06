//
//  LoginView.swift
//  Presentation
//
//  Created by 최정인 on 6/30/25.
//

import AuthenticationServices
import Combine
import Domain
import Shared
import SnapKit
import UIKit

final class LoginView: BaseViewController<LoginViewModel> {

    private enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let loginLabelTopSpacing: CGFloat = 54
        static let loginLabelHeight: CGFloat = 30
        static let logoBottomSpacing: CGFloat = 79
        static let logoLeadingSpacing: CGFloat = 53
        static let logoWidth: CGFloat = 257
        static let logoHeight: CGFloat = 295
        static let loginButtonHeight: CGFloat = 54
        static let loginButtonBottomSpacing: CGFloat = 20
        static let loginButtonSpacing: CGFloat = 12
    }

    private let loginLabel = UILabel()
    private let logoView = UIImageView()
    private let kakaoLoginButton = SocialLoginButton(socialType: .kakao)
    private let appleLoginButton = SocialLoginButton(socialType: .apple)
    private var cancellables: Set<AnyCancellable>
    private let onboardingRepository: OnboardingRepositoryProtocol

    init(onboardingRepository: OnboardingRepositoryProtocol, viewModel: LoginViewModel) {
        self.onboardingRepository = onboardingRepository
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
        loginLabel.text = "빛나길에 오신걸 환영해요!"
        loginLabel.font = BitnagilFont(style: .title2, weight: .bold).font
        loginLabel.textColor = BitnagilColor.navy500

        logoView.image = BitnagilGraphic.introGraphic

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

        view.addSubview(loginLabel)
        view.addSubview(logoView)
        view.addSubview(kakaoLoginButton)
        view.addSubview(appleLoginButton)

        loginLabel.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(Layout.loginLabelTopSpacing)
            make.height.equalTo(Layout.loginLabelHeight)
            make.centerX.equalToSuperview()
        }

        logoView.snp.makeConstraints { make in
            make.leading.equalTo(safeArea).offset(Layout.logoLeadingSpacing)
            make.bottom.equalTo(kakaoLoginButton.snp.top).offset(-Layout.logoBottomSpacing)
            make.width.equalTo(Layout.logoWidth)
            make.height.equalTo(Layout.logoHeight)
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
                    if onboardingRepository.isOnboardingDone() {
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                            window.rootViewController = TabBarView()
                        }
                    } else {
                        guard let onboardingViewModel = DIContainer.shared.resolve(type: OnboardingViewModel.self) else {
                            fatalError("onboardingViewModel 의존성이 등록되지 않았습니다.")
                        }
                        let onboardingView = OnboardingView(viewModel: onboardingViewModel, onboarding: .time)
                        self.navigationController?.pushViewController(onboardingView, animated: true)
                    }
                }
            }
            .store(in: &cancellables)
    }

    private func appleLogin() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]

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
