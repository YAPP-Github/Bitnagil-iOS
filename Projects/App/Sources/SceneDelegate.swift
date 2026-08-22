//
//  SceneDelegate.swift
//  App
//
//  Created by 최정인 on 6/15/25.
//

import AppTrackingTransparency
import Domain
import FacebookCore
import KakaoSDKAuth
import Presentation
import Shared
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)

        DIContainer.shared.dependencyInjection()

        let splashView = SplashViewController()
        splashView.delegate = self

        window.rootViewController = splashView
        window.makeKeyAndVisible()
        self.window = window
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.handleOpenUrl(url: url)
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) { }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // 유저가 설정 앱에서 추적 허용 여부를 바꿨을 수 있으므로, 활성화 시마다 최신 상태를 Meta SDK에 반영합니다.
        Settings.shared.isAdvertiserTrackingEnabled = (ATTrackingManager.trackingAuthorizationStatus == .authorized)
    }

    // 광고 어트리뷰션 정확도를 위해 앱 추적 투명성(ATT) 권한을 요청하고, 결과를 Meta SDK에 반영합니다.
    // 스플래시 애니메이션 완료 시점은 앱이 확실히 active 상태이므로 다이얼로그 표시가 보장됩니다.
    private func requestTrackingAuthorization() {
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else { return }

        ATTrackingManager.requestTrackingAuthorization { status in
            Settings.shared.isAdvertiserTrackingEnabled = (status == .authorized)
        }
    }

    func sceneWillResignActive(_ scene: UIScene) { }

    func sceneWillEnterForeground(_ scene: UIScene) { }

    func sceneDidEnterBackground(_ scene: UIScene) { }
}

extension SceneDelegate: SplashViewDelegate {
    func splashView(_ sender: Presentation.SplashViewController, isCompletedAnimated: Bool) {
        guard isCompletedAnimated else { return }

        requestTrackingAuthorization()

        guard let userDataRepository = DIContainer.shared.resolve(type: UserDataRepositoryProtocol.self)
        else { fatalError("userDataRepository 의존성이 등록되지 않았습니다.") }

        Task { @MainActor in
            let userState = await userDataRepository.reissueToken()
            switch userState {
            case .user:
                window?.rootViewController = TabBarView()

            case .guest, nil:
                guard let loginViewModel = DIContainer.shared.resolve(type: LoginViewModel.self)
                else { fatalError("loginViewModel 의존성이 등록되지 않았습니다.") }

                let loginView = LoginViewController(viewModel: loginViewModel)
                let navigationController = UINavigationController(rootViewController: loginView)
                window?.rootViewController = navigationController

            case .onboarding:
                guard let introViewModel = DIContainer.shared.resolve(type: IntroViewModel.self)
                else { fatalError("introViewModel 의존성이 등록되지 않았습니다.") }

                let introView = IntroViewController(viewModel: introViewModel)
                let navigationController = UINavigationController(rootViewController: introView)
                window?.rootViewController = navigationController
            }
        }
    }
}
