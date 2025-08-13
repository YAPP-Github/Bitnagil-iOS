//
//  LoginViewController.swift
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

public final class LoginViewController: BaseViewController<LoginViewModel> {
    private enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let loginLabelTopMinSpacing: CGFloat = 45
        static let loginLabelTopSpacing: CGFloat = 69
        static let loginLabelHeight: CGFloat = 64
        static let loginGraphicViewTopSpacing: CGFloat = 75
        static let loginGraphicViewLeadingSpacing: CGFloat = 30
        static let loginGraphicViewWidth: CGFloat = 287
        static let loginGraphicViewHeight: CGFloat = 307
        static let loginButtonHeight: CGFloat = 54
        static let loginButtonBottomSpacing: CGFloat = 20
        static let loginButtonSpacing: CGFloat = 12
    }

    private let loginLabel = UILabel()
    private let loginGraphicView = UIImageView()
    private let kakaoLoginButton = SocialLoginButton(socialType: .kakao)
    private let appleLoginButton = SocialLoginButton(socialType: .apple)
    private var isLayoutConfigured: Bool = false
    private var loginLabelTopConstraint: Constraint?
    private var loginGraphicViewTopConstraint: Constraint?
    private var cancellables: Set<AnyCancellable>

    public override init(viewModel: LoginViewModel) {
        cancellables = []
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !isLayoutConfigured {
            updateLoginGraphicViewTopSpacing()
            isLayoutConfigured = true
        }
    }

    private func updateLoginGraphicViewTopSpacing() {
        let height = view.bounds.height
        if height <= 667 {
            // loginLabel 레이아웃 업데이트
            loginLabelTopConstraint?.update(offset: Layout.loginLabelTopMinSpacing)

            // loginGraphicView 레이아웃 업데이트
            let loginLabelBottom = Layout.loginLabelTopMinSpacing + Layout.loginLabelHeight
            let kakaoLoginButtonTop = height - view.safeAreaInsets.bottom - (Layout.loginButtonBottomSpacing + Layout.loginButtonHeight * 2 + Layout.loginButtonSpacing)

            let middleSpacing = kakaoLoginButtonTop - loginLabelBottom
            let newTopSpacing = (middleSpacing - Layout.loginGraphicViewHeight) / 2

            loginGraphicViewTopConstraint?.update(offset: newTopSpacing)
        }
    }

    override func configureAttribute() {
        let loginText = "안녕! 저는 포모예요\n함께 빛나길을 시작해볼까요?"
        loginLabel.attributedText = BitnagilFont(style: .title1, weight: .bold).attributedString(text: loginText)
        loginLabel.font = BitnagilFont(style: .title1, weight: .bold).font
        loginLabel.textColor = BitnagilColor.gray10
        loginLabel.numberOfLines = 2

        loginGraphicView.image = BitnagilGraphic.loginGraphic

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
        navigationController?.setNavigationBarHidden(true, animated: false)

        view.addSubview(loginLabel)
        view.addSubview(loginGraphicView)
        view.addSubview(kakaoLoginButton)
        view.addSubview(appleLoginButton)

        loginLabel.snp.makeConstraints { make in
            loginLabelTopConstraint = make.top.equalTo(safeArea).offset(Layout.loginLabelTopSpacing).constraint
            make.leading.equalToSuperview().offset(Layout.horizontalMargin)
            make.height.equalTo(Layout.loginLabelHeight)
        }

        loginGraphicView.snp.makeConstraints { make in
            make.leading.equalTo(safeArea).offset(Layout.loginGraphicViewLeadingSpacing)
            loginGraphicViewTopConstraint = make.top.equalTo(loginLabel.snp.bottom).offset(Layout.loginGraphicViewTopSpacing).constraint
            make.width.equalTo(Layout.loginGraphicViewWidth)
            make.height.equalTo(Layout.loginGraphicViewHeight)
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
                switch userState {
                case .guest:
                    let agreementView = TermsAgreementViewController(viewModel: self.viewModel)
                    self.navigationController?.pushViewController(agreementView, animated: true)

                case .user:
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                        window.rootViewController = TabBarView()
                    }

                case .onboarding:
                    guard let introViewModel = DIContainer.shared.resolve(type: IntroViewModel.self)
                    else { fatalError("introViewModel 의존성이 등록되지 않았습니다.") }

                    let introViewController = IntroViewController(viewModel: introViewModel)
                    self.navigationController?.pushViewController(introViewController, animated: true)
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
extension LoginViewController: ASAuthorizationControllerDelegate {
    public func authorizationController(
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

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        BitnagilLogger.log(logType: .error, message: "Apple 로그인 실패")
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window ?? UIWindow()
    }
}
