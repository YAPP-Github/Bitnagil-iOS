//
//  MypageView.swift
//  Presentation
//
//  Created by 이동현 on 7/17/25.
//
import Combine
import SafariServices
import Shared
import SnapKit
import UIKit

final class MypageView: BaseViewController<MypageViewModel> {
    private enum Layout {
        static let profileImageViewSize: CGFloat = 80
        static let profileImageViewCornerRadius: CGFloat = profileImageViewSize / 2
        static let profileImageViewTopSpacing: CGFloat = 32
        static let nicknameLabelHeight: CGFloat = 24
        static let nicknameLabelTopSpacing: CGFloat = 12
        static let divideLineHeight: CGFloat = 6
        static let divideLineTopSpacing: CGFloat = 28
        static let tableViewCellHeight: CGFloat = 48
    }

    private let titleLabel = UILabel()
    private let settingButton = UIBarButtonItem()
    private let profileImageView = UIImageView()
    private let nicknameLabel = UILabel()
    private let dividerView = UIView()
    private let tableView = UITableView()
    private var cancellables: Set<AnyCancellable>

    override init(viewModel: MypageViewModel) {
        cancellables = []
        super.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: animated)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.isHidden = false
    }

    override func configureAttribute() {
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = settingButton
        title = "마이페이지"

        settingButton.action = #selector(settingButtonTapped)
        settingButton.target = self
        settingButton.image = BitnagilIcon.settingIcon?.withRenderingMode(.alwaysOriginal)
        profileImageView.image = BitnagilGraphic.profileGraphic

        nicknameLabel.font = BitnagilFont(style: .title3, weight: .semiBold).font
        nicknameLabel.textColor = .black
        nicknameLabel.textAlignment = .center

        dividerView.backgroundColor = BitnagilColor.gray99

        tableView.register(BitnagilChevronTableViewCell.self, forCellReuseIdentifier: BitnagilChevronTableViewCell.className)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.bounces = false
    }

    override func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        view.addSubview(profileImageView)
        view.addSubview(nicknameLabel)
        view.addSubview(dividerView)
        view.addSubview(tableView)

        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(safeArea.snp.top).offset(Layout.profileImageViewTopSpacing)
            make.centerX.equalToSuperview()
            make.size.equalTo(Layout.profileImageViewSize)
        }

        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(Layout.nicknameLabelTopSpacing)
            make.centerX.equalToSuperview()
            make.height.equalTo(Layout.nicknameLabelHeight)
        }

        dividerView.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(Layout.divideLineTopSpacing)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(Layout.divideLineHeight)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(dividerView.snp.bottom)
            make.horizontalEdges.bottom.equalTo(safeArea)
        }

    }

    override func bind() {
        viewModel.output.nickNamePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] nickname in
                self?.nicknameLabel.text = nickname
            }
            .store(in: &cancellables)

        viewModel.output.externalURLPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] url in
                let safariView = SFSafariViewController(url: url)
                self?.present(safariView, animated: true)
            }
            .store(in: &cancellables)
    }

    @objc private func settingButtonTapped() {
        guard let settingViewModel = Shared.DIContainer.shared.resolve(type: SettingViewModel.self) else { return }
        let settingView = SettingView(viewModel: settingViewModel)
        navigationController?.pushViewController(settingView, animated: true)
    }
}

extension MypageView: UITableViewDelegate {

}

extension MypageView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MypageViewModel.MypageMenu.allCases.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Layout.tableViewCellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BitnagilChevronTableViewCell.className) as? BitnagilChevronTableViewCell else {
            return .init()
        }

        let title = MypageViewModel.MypageMenu
            .allCases[indexPath.row]
            .rawValue
        cell.configure(title: title)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { tableView.deselectRow(at: indexPath, animated: true) }

        let selectedMenu = MypageViewModel.MypageMenu.allCases[indexPath.row]

        guard selectedMenu == .resetGoal else {
            viewModel.action(input: .didSelectMenu(menu: selectedMenu))
            return
        }

        guard let onboardingViewModel = DIContainer.shared.resolve(type: OnboardingViewModel.self)
        else { fatalError("onboardingViewModel 의존성이 등록되지 않았습니다.") }

        let onboardingView = OnboardingResultViewController(viewModel: onboardingViewModel, entryPoint: .myPagePrevious)
        onboardingView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(onboardingView, animated: true)
    }
}
