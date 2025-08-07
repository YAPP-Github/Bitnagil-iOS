//
//  SettingViewModel.swift
//  Presentation
//
//  Created by 이동현 on 7/30/25.
//

import Combine
import Domain
import Foundation

final class SettingViewModel: ViewModel {
    enum URLType {
        case update
        case terms
        case privacy

        fileprivate var url: URL? {
            switch self {
            case .update:
                return URL(string: "itms-apps://itunes.apple.com/app/{빛나길 id}")
            case .terms:
                return URL(string: "https://complex-wombat-99f.notion.site/2025-7-20-236f4587491d8071833adfaf8115bce2")
            case .privacy:
                return URL(string: "https://complex-wombat-99f.notion.site/2025-07-20-236f4587491d80308016eb810692d18b")
            }
        }
    }

    enum OpenURLType {
        case `internal`(url: URL)
        case external(url: URL)
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
        case fetchVersion
    }

    struct Output {
        let generalNotificationEnabled: AnyPublisher<Bool, Never>
        let pushNotificationEnabled: AnyPublisher<Bool, Never>
        let versionPublisher: AnyPublisher<VersionType, Never>
        let urlPublisher: AnyPublisher<OpenURLType, Never>
        let isAuthenticatedPublisher: AnyPublisher<Bool, Never>
    }

    private(set) var output: Output
    private let versionSubject = PassthroughSubject<VersionType, Never>()
    private let generalNoticeEnabledSubject = CurrentValueSubject<Bool, Never>(false)
    private let pushNoticeEnabledSubject = CurrentValueSubject<Bool, Never>(true)
    private let urlSubject = PassthroughSubject<OpenURLType, Never>()
    private let authenticatedSubject = PassthroughSubject<Bool, Never>()
    private var authRepository: AuthRepositoryProtocol?
    private var appConfigRepository: AppConfigRepositoryProtocol?

    init() {
        output = .init(
            generalNotificationEnabled: generalNoticeEnabledSubject.eraseToAnyPublisher(),
            pushNotificationEnabled: pushNoticeEnabledSubject.eraseToAnyPublisher(),
            versionPublisher: versionSubject.eraseToAnyPublisher(),
            urlPublisher: urlSubject.eraseToAnyPublisher(),
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
        case .openURL(let type):
            handleURL(type: type)
        case .logout:
            logout()
        case .withdrawal:
            withdrawal()
        case .fetchVersion:
            fetchVersion()
        }
    }

    func configure(authRepository: AuthRepositoryProtocol, appConfigRepository: AppConfigRepositoryProtocol) {
        self.authRepository = authRepository
        self.appConfigRepository = appConfigRepository
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
        guard let url = URLType.update.url else { return }
        urlSubject.send(.external(url: url))
    }

    private func logout() {
        Task {
            do {
                try await authRepository?.logout()
                authenticatedSubject.send(false)
            } catch {
                // TODO: - 토스트 팝업 구현 시 + 디자인 추가 시 네트워크 불안정 알림
            }
        }
    }

    private func withdrawal() {
        Task {
            do {
                try await authRepository?.withdraw()
                authenticatedSubject.send(false)
            } catch {
                // TODO: - 토스트 팝업 구현 시 + 디자인 추가 시 네트워크 불안정 알림
            }
        }
    }

    private func fetchVersion() {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

        Task {
            do {
                let appStoreAppVersion = try await appConfigRepository?.fetchAppVersion()

                if currentVersion != appStoreAppVersion {
                    versionSubject.send(.needUpdate(version: currentVersion ?? ""))
                } else {
                    versionSubject.send(.latest(version: currentVersion ?? ""))
                }
            } catch {

            }
        }
    }

    private func handleURL(type: URLType) {
        guard let url = type.url else { return }

        urlSubject.send(.internal(url: url))
    }
}
