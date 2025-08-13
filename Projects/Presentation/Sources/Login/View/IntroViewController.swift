//
//  IntroViewController.swift
//  Presentation
//
//  Created by 최정인 on 7/6/25.
//

import Combine
import Domain
import Shared
import SnapKit
import UIKit

public final class IntroViewController: BaseViewController<IntroViewModel> {
    private enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let labelTopMinSpacing: CGFloat = 45
        static let labelTopSpacing: CGFloat = 69
        static let labelHeight: CGFloat = 32
        static let labelGraphicViewTopMinSpacing: CGFloat = 25
        static let labelGraphicViewTopSpacing: CGFloat = 48
        static let labelGraphicViewWidth: CGFloat = 303
        static let labelGraphicViewHeight: CGFloat = 161.48
        static let fomoGraphViewTopSpacing: CGFloat = 30.52
        static let fomoGraphViewTrailingSpacing: CGFloat = 29
        static let fomoGraphViewWidth: CGFloat = 263
        static let fomoGraphViewHeight: CGFloat = 254
        static let startButtonBottomSpacing: CGFloat = 20
        static let startButtonHeight: CGFloat = 54
    }

    private let introLabel = UILabel()
    private let labelGraphicView = UIImageView()
    private let fomoGraphView = UIImageView()
    private let startButton = PrimaryButton(buttonState: .default, buttonTitle: "포모에게 알려주기")
    private var isLayoutConfigured: Bool = false
    private var introLabelTopConstraint: Constraint?
    private var labelGraphicViewTopConstraint: Constraint?
    private var cancellables: Set<AnyCancellable> = []

    public override init(viewModel: IntroViewModel) {
        cancellables = []
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.action(input: .loadNickname)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !isLayoutConfigured {
            updateConstraints()
            isLayoutConfigured = true
        }
    }

    private func updateConstraints() {
        let height = view.bounds.height
        if height <= 667 {
            introLabelTopConstraint?.update(offset: Layout.labelTopMinSpacing)
            labelGraphicViewTopConstraint?.update(offset: Layout.labelGraphicViewTopMinSpacing)
        }
    }

    override func configureAttribute() {
        introLabel.text = "포모는 님을 알고싶어요!"
        introLabel.font = BitnagilFont(style: .title1, weight: .bold).font
        introLabel.textColor = BitnagilColor.gray10

        labelGraphicView.image = BitnagilGraphic.introLabelGraphic
        fomoGraphView.image = BitnagilGraphic.introFomoGraphic

        startButton.addAction(
            UIAction { [weak self] _ in
                guard let onboardingViewModel = DIContainer.shared.resolve(type: OnboardingViewModel.self)
                else { fatalError("onboardingViewModel 의존성이 등록되지 않았습니다.") }

                let onboardingView = OnboardingViewController(viewModel: onboardingViewModel, onboarding: .time)
                self?.navigationController?.pushViewController(onboardingView, animated: true)
            }, for: .touchUpInside)
    }

    override func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        view.backgroundColor = BitnagilColor.gray99
        navigationController?.setNavigationBarHidden(true, animated: false)

        view.addSubview(introLabel)
        view.addSubview(labelGraphicView)
        view.addSubview(fomoGraphView)
        view.addSubview(startButton)

        introLabel.snp.makeConstraints { make in
            introLabelTopConstraint = make.top.equalTo(safeArea).offset(Layout.labelTopSpacing).constraint
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.height.equalTo(Layout.labelHeight)
        }

        labelGraphicView.snp.makeConstraints { make in
            labelGraphicViewTopConstraint = make.top.equalTo(introLabel.snp.bottom).offset(Layout.labelGraphicViewTopSpacing).constraint
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.width.equalTo(Layout.labelGraphicViewWidth)
            make.height.equalTo(Layout.labelGraphicViewHeight)
        }

        fomoGraphView.snp.makeConstraints { make in
            make.top.equalTo(labelGraphicView.snp.bottom).offset(Layout.fomoGraphViewTopSpacing)
            make.trailing.equalTo(safeArea).inset(Layout.fomoGraphViewTrailingSpacing)
            make.width.equalTo(Layout.fomoGraphViewWidth)
            make.height.equalTo(Layout.fomoGraphViewHeight)
        }

        startButton.snp.makeConstraints { make in
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.trailing.equalTo(safeArea).inset(Layout.horizontalMargin)
            make.bottom.equalTo(safeArea).inset(Layout.startButtonBottomSpacing)
            make.height.equalTo(Layout.startButtonHeight)
        }
    }

    override func bind() {
        viewModel.output.nicknamePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] nickname in
                self?.introLabel.text = "포모는 \(nickname)님을 알고싶어요!"
            }
            .store(in: &cancellables)
    }
}
