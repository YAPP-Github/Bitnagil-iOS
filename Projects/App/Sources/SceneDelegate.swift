//
//  SceneDelegate.swift
//  App
//
//  Created by 최정인 on 6/15/25.
//

import Domain
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

        let splashView = SplashView()
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

    func sceneDidBecomeActive(_ scene: UIScene) { }

    func sceneWillResignActive(_ scene: UIScene) { }

    func sceneWillEnterForeground(_ scene: UIScene) { }

    func sceneDidEnterBackground(_ scene: UIScene) { }
}

extension SceneDelegate: SplashViewDelegate {
    func splashView(_ sender: Presentation.SplashView, isCompletedAnimated: Bool) {
        guard isCompletedAnimated else { return }

        guard let userDataRepository = DIContainer.shared.resolve(type: UserDataRepositoryProtocol.self)
        else { fatalError("userDataRepository 의존성이 등록되지 않았습니다.") }

        Task { @MainActor in
            let isLogined = await userDataRepository.reissueToken()
            if isLogined {
                window?.rootViewController = TabBarView()
            } else {
                let introView = IntroView()
                let navigationController = UINavigationController(rootViewController: introView)
                window?.rootViewController = navigationController
            }
        }
    }
}
