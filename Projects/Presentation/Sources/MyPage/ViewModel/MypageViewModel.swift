//
//  MyPageViewModel.swift
//  Presentation
//
//  Created by 이동현 on 7/17/25.
//

import Combine
import Domain
import Foundation
import Shared

final class MypageViewModel: ViewModel {
    enum Input {
        case didSelectMenu(menu: MypageMenu)
    }

    struct Output {
        let nickNamePublisher: AnyPublisher<String, Never>
        let externalURLPublisher: AnyPublisher<URL, Never>
    }

    enum MypageMenu: String, CaseIterable {
        case resetGoal = "내 목표 재설정"
        case notice = "공지사항"
        case faq = "자주 묻는 질문"
    }

    private(set) var output: Output
    private let nicknamePublisher = CurrentValueSubject<String, Never>("")
    private let externalURLPublisher = PassthroughSubject<URL, Never>()
    private let userDataRepository: UserDataRepositoryProtocol

    init(userDataRepository: UserDataRepositoryProtocol) {
        self.userDataRepository = userDataRepository

        output = .init(
            nickNamePublisher: nicknamePublisher.eraseToAnyPublisher(),
            externalURLPublisher: externalURLPublisher.eraseToAnyPublisher())

        Task {
            do {
                let nickname = try await userDataRepository.loadNickname()
                nicknamePublisher.send(nickname)
            } catch {
                BitnagilLogger.log(logType: .debug, message: "\(error.localizedDescription)")
            }
        }
    }

    func action(input: Input) {
        switch input {
        case .didSelectMenu(let menu):
            handleMenuSelection(menu: menu)
        }
    }

    private func handleMenuSelection(menu: MypageMenu) {
        switch menu {
        case .resetGoal:
            break
        case .notice: // 임시 url
            if let url = URL(string: "https://complex-wombat-99f.notion.site/23ff4587491d80efa0a5e4baece6017b") {
                externalURLPublisher.send(url)
            }
        case .faq: // 임시 url
            if let url = URL(string: "https://complex-wombat-99f.notion.site/23ff4587491d80659ae3ea392afbc05e") {
                externalURLPublisher.send(url)
            }
        }
    }
}
