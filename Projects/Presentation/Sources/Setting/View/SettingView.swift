//
//  SettingViewController.swift
//  Presentation
//
//  Created by 이동현 on 7/27/25.
//

import Combine
import Domain
import SafariServices
import Shared
import SnapKit
import UIKit

final class SettingView: BaseViewController<SettingViewModel> {
    private enum Layout {
        static let tableViewTopSpacing: CGFloat = 80
        static let tableViewHeaderHeight: CGFloat = 48
        static let tableViewRowHeight: CGFloat = 48
        static let tableViewFooterHeight: CGFloat = .zero
    }

    private enum CellStyle {
        case toggle(title: String)
        case button(title: String)
        case chevron(title: String)
    }

    private enum Section: Int, CaseIterable {
//        case notification
        case information
        case account

        var title: String {
            switch self {
//            case .notification:
//                return "알림"
            case .information:
                return "정보"
            case .account:
                return "계정"
            }
        }
    }

    private enum NotificationSection: Int, CaseIterable, CustomStringConvertible {
        case general
        case push

        var description: String {
            switch self {
            case .general:
                return "서비스 이용 알림"
            case .push:
                return "푸시알림"
            }
        }

        var cellStyle: CellStyle {
            return .toggle(title: description)
        }
    }

    private enum InformationSection: Int, CaseIterable, CustomStringConvertible {
        case version
        case terms
        case privacy

        var description: String {
            switch self {
            case .version:
                return "버전"
            case .terms:
                return "서비스 이용약관"
            case .privacy:
                return "개인정보처리방침"
            }
        }

        var cellStyle: CellStyle {
            switch self {
            case .version:
                return .button(title: description)
            default:
                return .chevron(title: description)
            }
        }
    }

    private enum AccountSection: CaseIterable, CustomStringConvertible {
        case logout
        case withdrawal

        var description: String {
            switch self {
            case .logout:
                return "로그아웃"
            case .withdrawal:
                return "탈퇴하기"
            }
        }

        var cellStyle: CellStyle {
            return .chevron(title: description)
        }
    }

    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var cancellables = Set<AnyCancellable>()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        configureCustomNavigationBar(navigationBarStyle: .withBackButton(title: "설정"))
    }

    override func configureAttribute() {
        view.backgroundColor = .white

        guard
            let authRepository = DIContainer.shared.resolve(type: AuthRepositoryProtocol.self),
            let appConfigRepository = DIContainer.shared.resolve(type: AppConfigRepositoryProtocol.self)
        else { fatalError("authRepository, appConfigRepository 의존성이 등록되지 않았습니다.") }

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.register(BitnagilToggleTableViewCell.self, forCellReuseIdentifier: BitnagilToggleTableViewCell.className)
        tableView.register(BitnagilButtonTableViewCell.self, forCellReuseIdentifier: BitnagilButtonTableViewCell.className)
        tableView.register(BitnagilChevronTableViewCell.self, forCellReuseIdentifier: BitnagilChevronTableViewCell.className)
        tableView.register(SettingHeaderView.self, forHeaderFooterViewReuseIdentifier: SettingHeaderView.className)
        viewModel.configure(authRepository: authRepository, appConfigRepository: appConfigRepository)
        viewModel.action(input: .fetchVersion)
    }

    override func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide

        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.top.equalTo(safeArea.snp.top).offset(Layout.tableViewTopSpacing)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(safeArea.snp.bottom)
        }
    }

    override func bind() {
//        viewModel.output.generalNotificationEnabled
//            .receive(on: DispatchQueue.main)
//            .sink(receiveValue: { [weak self] isEnabled in
//                let indexPath = IndexPath(row: NotificationSection.general.rawValue, section: Section.notification.rawValue)
//                guard
//                    let self,
//                    let cell = self.tableView.cellForRow(at: indexPath) as? BitnagilToggleTableViewCell
//                else { return }
//
//                cell.configureToggleState(isOn: isEnabled)
//            })
//            .store(in: &cancellables)
//
//        viewModel.output.pushNotificationEnabled
//            .receive(on: DispatchQueue.main)
//            .sink(receiveValue: { [weak self] isEnabled in
//                let indexPath = IndexPath(row: NotificationSection.push.rawValue, section: Section.notification.rawValue)
//                guard
//                    let self,
//                    let cell = self.tableView.cellForRow(at: indexPath) as? BitnagilToggleTableViewCell
//                else { return }
//
//                cell.configureToggleState(isOn: isEnabled)
//            })
//            .store(in: &cancellables)

        viewModel.output.urlPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] urlType in
                switch urlType {
                case .internal(let url):
                    let safariView = SFSafariViewController(url: url)
                    self?.present(safariView, animated: true)
                case .external(let url):
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            })
            .store(in: &cancellables)

        viewModel.output.versionPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] versionType in
                let indexPath = IndexPath(row: InformationSection.version.rawValue, section: Section.information.rawValue)
                guard
                    let self,
                    let cell = self.tableView.cellForRow(at: indexPath) as? BitnagilButtonTableViewCell
                else { return }

                switch versionType {
                case .needUpdate(let version):
                    cell.configure(title: "버전 \(version)", buttonTitle: "업데이트", isButtonEnabled: true)
                case .latest(let version):
                    cell.configure(title: "버전 \(version)", buttonTitle: "최신", isButtonEnabled: false)
                }
            })
            .store(in: &cancellables)

        viewModel.output.isAuthenticatedPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { isAuthenticated in
                if !isAuthenticated {
                    guard
                        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                        let sceneDelegate = windowScene.delegate as? UIWindowSceneDelegate,
                        let window = sceneDelegate.window
                    else { return }

                    guard let loginViewModel = DIContainer.shared.resolve(type: LoginViewModel.self)
                    else { fatalError("loginViewModel 의존성이 등록되지 않았습니다.") }

                    let loginView = LoginViewController(viewModel: loginViewModel)
                    let navigationController = UINavigationController(rootViewController: loginView)
                    window?.rootViewController = navigationController
                    window?.makeKeyAndVisible()
                }
            })
            .store(in: &cancellables)
    }
}

extension SettingView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = Section.allCases[indexPath.section]

        switch section {
//        case .notification:
//            return
        case .information:
            let row = InformationSection.allCases[indexPath.row]
            switch row {
            case .version:
                break
            case .terms:
                viewModel.action(input: .openURL(type: .terms))
            case .privacy:
                viewModel.action(input: .openURL(type: .privacy))
            }
        case .account:
            let alert: BitnagilAlert
            let row = AccountSection.allCases[indexPath.row]
            switch row {
            case .logout:
                alert = BitnagilAlert(
                    alertType: .withImage,
                    title: "로그아웃 하시겠어요?",
                    content: "버튼을 누르면 로그인 페이지로 이동해요.",
                    cancelButtonTitle: "취소",
                    confirmButtonTitle: "로그아웃",
                    cancelHandler: nil,
                    confirmHandler: { [weak self] in
                        self?.viewModel.action(input: .logout)
                    })
            case .withdrawal:
                alert = BitnagilAlert(
                    alertType: .withImage,
                    title: "정말 탈퇴하시겠어요?",
                    content: "소중한 기록들이 모두 사라져요.",
                    cancelButtonTitle: "취소",
                    confirmButtonTitle: "회원탈퇴",
                    cancelHandler: nil,
                    confirmHandler: { [weak self] in
                        self?.viewModel.action(input: .withdrawal)
                    })
            }
            alert.modalPresentationStyle = .overFullScreen
            present(alert, animated: false)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SettingView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section.allCases[section] {
//        case .notification:
//            return NotificationSection.allCases.count
        case .information:
            return InformationSection.allCases.count
        case .account:
            return AccountSection.allCases.count
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = Section.allCases[indexPath.section]

        let cellStyle: CellStyle

        switch section {
//        case .notification:
//            let row = NotificationSection.allCases[indexPath.row]
//            cellStyle = row.cellStyle
        case .information:
            let row = InformationSection.allCases[indexPath.row]
            cellStyle = row.cellStyle
        case .account:
            let row = AccountSection.allCases[indexPath.row]
            cellStyle = row.cellStyle
        }

        switch cellStyle {
        case .toggle(let title):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: BitnagilToggleTableViewCell.className, for: indexPath) as? BitnagilToggleTableViewCell else { return .init() }
            cell.configure(title: title)
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
        case .button(let title):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: BitnagilButtonTableViewCell.className, for: indexPath) as? BitnagilButtonTableViewCell else { return .init() }
            cell.configure(title: title)
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
        case .chevron(let title):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: BitnagilChevronTableViewCell.className, for: indexPath) as? BitnagilChevronTableViewCell else { return .init() }
            cell.configure(title: title)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = Section.allCases[section]

        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SettingHeaderView.className) as? SettingHeaderView else { return nil }

        switch section {
//        case .notification:
//            let view = UIView()
//            view.backgroundColor = .white
//            return view
        case .information:
            headerView.configure(shouldShowDivider: false, title: section.title)
            return headerView
        default:
            headerView.configure(shouldShowDivider: true, title: section.title)
            return headerView
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section = Section.allCases[section]

        switch section {
//        case .notification:
//            return Layout.tableViewTopSpacing
        default:
            return Layout.tableViewHeaderHeight
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return Layout.tableViewFooterHeight
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Layout.tableViewRowHeight
    }
}

extension SettingView: BitnagilButtonTableViewCellDelegate {
    func bitnagilButtonTableViewCellDidTapButton(_ sender: BitnagilButtonTableViewCell) {
        guard let indexPath = tableView.indexPath(for: sender) else { return }

        let section = Section.allCases[indexPath.section]
        switch section {
        case .information:
            let row = InformationSection.allCases[indexPath.row]
            switch row {
            case .version:
                viewModel.action(input: .update)
            default: break
            }
        default:
            break
        }
    }
}

extension SettingView: BitnagilToggleTableViewCellDelegate {
    func bitnagilToggleTableViewCellDidToggle(_ sender: BitnagilToggleTableViewCell, isOn: Bool) {
        guard let indexPath = tableView.indexPath(for: sender) else { return }

        let section = Section.allCases[indexPath.section]
        switch section {
//        case .notification:
//            let row = NotificationSection.allCases[indexPath.row]
//            switch row {
//            case .general:
//                viewModel.action(input: .toggleGeneralNotification)
//            case .push:
//                viewModel.action(input: .togglePushNotification)
//            }
        default:
            break
        }
    }
}
