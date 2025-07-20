//
//  MypageView.swift
//  Presentation
//
//  Created by 이동현 on 7/17/25.
//
import Combine
import Shared
import SnapKit
import UIKit

final class MypageView: BaseViewController<MypageViewModel> {
    private enum Layout {
        static let titleLabelHeight: CGFloat = 54
        static let settingButtonSize: CGFloat = 48
        static let settingButtonTrailingSpacing: CGFloat = 8
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
    private let settingButton = UIButton()
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

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func configureAttribute() {
        view.backgroundColor = .white

        titleLabel.text = "마이페이지"
        titleLabel.font = BitnagilFont(style: .title3, weight: .semiBold).font
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black

        settingButton.setImage(BitnagilIcon.settingIcon, for: .normal)

        profileImageView.layer.cornerRadius = Layout.profileImageViewCornerRadius
        profileImageView.layer.masksToBounds = true
        profileImageView.backgroundColor = BitnagilColor.gray40 // 임시

        nicknameLabel.font = BitnagilFont(style: .title3, weight: .semiBold).font
        nicknameLabel.textColor = .black
        nicknameLabel.textAlignment = .center

        dividerView.backgroundColor = BitnagilColor.gray99

        tableView.register(MypageTableViewCell.self, forCellReuseIdentifier: MypageTableViewCell.className)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
    }

    override func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        view.addSubview(titleLabel)
        view.addSubview(settingButton)
        view.addSubview(profileImageView)
        view.addSubview(nicknameLabel)
        view.addSubview(dividerView)
        view.addSubview(tableView)

        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.top.equalTo(safeArea)
            make.height.equalTo(Layout.titleLabelHeight)
        }

        settingButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(Layout.settingButtonTrailingSpacing)
            make.size.equalTo(Layout.settingButtonSize)
        }

        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Layout.profileImageViewTopSpacing)
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
            .sink { [weak self] nickname in
                self?.nicknameLabel.text = nickname
            }
            .store(in: &cancellables)

        viewModel.output.externalURLPublisher
            .sink { url in
                UIApplication.shared.open(url)
            }
            .store(in: &cancellables)
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
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: MypageTableViewCell.className) as? MypageTableViewCell
        else { return .init() }

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

        guard let onboardingViewModel = DIContainer.shared.resolve(type: OnboardingViewModel.self) else {
            fatalError("onboardingViewModel 의존성이 등록되지 않았습니다.")
        }

        let onboardingView = OnboardingView(viewModel: onboardingViewModel, onboarding: .time)
        navigationController?.pushViewController(onboardingView, animated: true)
    }
}
