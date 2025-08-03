//
//  SettingViewModel.swift
//  Presentation
//
//  Created by 이동현 on 7/30/25.
//

import Combine
import Foundation

final class SettingViewModel: ViewModel {
    enum URLType {
        case terms
        case privacy

        fileprivate var url: URL? {
            switch self {
            case .terms:
                return URL(string: "https://complex-wombat-99f.notion.site/2025-7-20-236f4587491d8071833adfaf8115bce2")
            case .privacy:
                return URL(string: "https://complex-wombat-99f.notion.site/2025-07-20-236f4587491d80308016eb810692d18b")
            }
        }
    }

    enum VersionType {
        case needUpdate(version: String)
        case latest(version: String)
    }

    enum Input {
        case toggleGeneralNotification
        case togglePushNotification
        case update
        case openURL(type: URLType)
        case logout
        case withdrawal
    }

    struct Output {
        let generalNotificationEnabled: AnyPublisher<Bool, Never>
        let pushNotificationEnabled: AnyPublisher<Bool, Never>
        let versionPublisher: AnyPublisher<VersionType, Never>
        let urlPublisher: AnyPublisher<URL?, Never>
        let isAuthenticatedPublisher: AnyPublisher<Bool, Never>
    }

    private(set) var output: Output
    private let versionSubject = CurrentValueSubject<VersionType, Never>(.latest(version: "1.0.0"))
    private let generalNoticeEnabledSubject = CurrentValueSubject<Bool, Never>(false)
    private let pushNoticeEnabledSubject = CurrentValueSubject<Bool, Never>(true)
    private let externalURLSubject = PassthroughSubject<URL?, Never>()
    private let authenticatedSubject = PassthroughSubject<Bool, Never>()
    

    init() {
        output = .init(
            generalNotificationEnabled: generalNoticeEnabledSubject.eraseToAnyPublisher(),
            pushNotificationEnabled: pushNoticeEnabledSubject.eraseToAnyPublisher(),
            versionPublisher: versionSubject.eraseToAnyPublisher(),
            urlPublisher: externalURLSubject.eraseToAnyPublisher(),
            isAuthenticatedPublisher: authenticatedSubject.eraseToAnyPublisher())
    }

    func action(input: Input) {
        switch input {
        case .toggleGeneralNotification:
            toggleGeneralNotification()
        case .togglePushNotification:
            togglePushNotification()
        case .update:
            updateBitnagil()
        case .openURL(type: let type):
            externalURLSubject.send(type.url)
        case .logout:
            logout()
        case .withdrawal:
            withdrawal()
        }
    }

    private func toggleGeneralNotification() {
        var generalNotificationEnabled = generalNoticeEnabledSubject.value
        generalNotificationEnabled.toggle()
        generalNoticeEnabledSubject.send(generalNotificationEnabled)
    }

    private func togglePushNotification() {
        var pushNotificationEnabled = pushNoticeEnabledSubject.value
        pushNotificationEnabled.toggle()
        pushNoticeEnabledSubject.send(pushNotificationEnabled)
    }

    private func updateBitnagil() {
        // TODO: - 앱스토어 열기
    }

    private func logout() {
        // TODO: - 로그아웃 api
    }

    private func withdrawal() {
        // TODO: - 회원탈퇴 api
    }
}
