//
//  AppDelegate.swift
//  App
//
//  Created by 최정인 on 6/15/25.
//

import DataSource
import FacebookCore
import KakaoSDKCommon
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        KakaoSDK.initSDK(appKey: AppProperties.kakaoNativeKey)
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

        #if DEBUG
        // Meta 이벤트 전송 여부를 Xcode 콘솔에서 확인하기 위한 로깅 (디버그 빌드 전용)
        Settings.shared.enableLoggingBehavior(.appEvents)
        Settings.shared.enableLoggingBehavior(.networkRequests)
        #endif

        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {

    }
}

