//
//  OnboardingRecommendedRoutineView.swift
//  Presentation
//
//  Created by 최정인 on 7/11/25.
//

import Combine
import Domain
import Shared
import UIKit

final class OnboardingRecommendedRoutineView: BaseViewController<OnboardingViewModel> {

    private enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let mainLabelHeight: CGFloat = 60
        static let subLabelTopSpacing: CGFloat = 10
        static let subLabelHeight: CGFloat = 40
        static let routineStackViewSpacing: CGFloat = 12
        static let routineStackViewTopSpacing: CGFloat = 28
        static let routineButtonHeight: CGFloat = 84
        static let registerButtonHeight: CGFloat = 54
        static let registerButtonBottomSpacing: CGFloat = 10
        static let skipButtonHeight: CGFloat = 54
        static let skipButtonBottomSpacing: CGFloat = 20

        static var mainLabelTopSpacing: CGFloat {
            let height = UIScreen.main.bounds.height
            if height <= 667 { return 12 }
            else { return 32 }
        }
    }

    private let mainLabel = UILabel()
    private var subLabel = UILabel()
    private let recommendedRoutineStackView = UIStackView()
    private var recommendedRoutines: [Int: OnboardingChoiceButton] = [:]
    private let registerButton = PrimaryButton(buttonState: .disabled, buttonTitle: "등록하기")
    private let skipButtonLabel = UILabel()
    private let skipButton = UIButton()
    private var cancellables: Set<AnyCancellable>

    override init(viewModel: OnboardingViewModel) {
        cancellables = []
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.action(input: .registerOnboarding)

        let stepCount = OnboardingType.allCases.count + 1
        configureNavigationBar(navigationStyle: .withPrograssBarWithCustomBackButton(step: stepCount, stepCount: stepCount))
    }

    override func configureAttribute() {
        mainLabel.do {
            let text = "당신만의 추천 루틴이\n생성되었어요!"
            $0.attributedText = BitnagilFont(style: .title2, weight: .bold).attributedString(text: text)
            $0.textColor = BitnagilColor.navy500
            $0.numberOfLines = 2
            $0.textAlignment = .left
        }

        subLabel.do {
            let text = "당신의 생활 패턴과 목표에 맞춰 구성된 맞춤 루틴이에요.\n원하는 루틴을 선택해서 가볍게 시작해보세요."
            $0.attributedText = BitnagilFont(style: .body2, weight: .medium).attributedString(text: text)
            $0.textColor = BitnagilColor.gray50
            $0.numberOfLines = 2
            $0.textAlignment = .left
        }

        recommendedRoutineStackView.do {
            $0.axis = .vertical
            $0.spacing = Layout.routineStackViewSpacing
        }

        registerButton.addAction(UIAction { [weak self] _ in
            self?.viewModel.action(input: .registerRecommendedRoutine)
        }, for: .touchUpInside)

        skipButtonLabel.do {
            $0.attributedText = BitnagilFont(
                fontSize: 14,
                lineHeight: 20,
                underline: true,
                weight: .regular
            ).attributedString(text: "건너뛰기")
            $0.textColor = BitnagilColor.navy500
        }

        skipButton.addAction(UIAction { [weak self] _ in
            self?.goToHomeView()
        }, for: .touchUpInside)
    }

    override func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        view.backgroundColor = BitnagilColor.gray99

        view.addSubview(mainLabel)
        view.addSubview(subLabel)
        view.addSubview(recommendedRoutineStackView)
        view.addSubview(registerButton)
        skipButton.addSubview(skipButtonLabel)
        view.addSubview(skipButton)

        mainLabel.snp.makeConstraints { make in
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.trailing.equalTo(safeArea).inset(Layout.horizontalMargin)
            make.top.equalTo(safeArea).offset(Layout.mainLabelTopSpacing)
            make.height.equalTo(Layout.mainLabelHeight)
        }

        subLabel.snp.makeConstraints { make in
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.trailing.equalTo(safeArea).inset(Layout.horizontalMargin)
            make.top.equalTo(mainLabel.snp.bottom).offset(Layout.subLabelTopSpacing)
            make.height.equalTo(Layout.subLabelHeight)
        }

        recommendedRoutineStackView.snp.makeConstraints { make in
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.trailing.equalTo(safeArea).inset(Layout.horizontalMargin)
            make.top.equalTo(subLabel.snp.bottom).offset(Layout.routineStackViewTopSpacing)
        }

        registerButton.snp.makeConstraints { make in
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.trailing.equalTo(safeArea).inset(Layout.horizontalMargin)
            make.bottom.equalTo(skipButton.snp.top).offset(-Layout.registerButtonBottomSpacing)
            make.height.equalTo(Layout.registerButtonHeight)
        }

        skipButtonLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        skipButton.snp.makeConstraints { make in
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.trailing.equalTo(safeArea).inset(Layout.horizontalMargin)
            make.bottom.equalTo(safeArea).inset(Layout.skipButtonBottomSpacing)
            make.height.equalTo(Layout.skipButtonHeight)
        }
    }

    override func bind() {
        viewModel.output.recommendedRoutinePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] recommendedRoutines in
                self?.updateRecommendedRoutines(routines: recommendedRoutines)
            }
            .store(in: &cancellables)

        viewModel.output.selectedRoutinePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedRoutines in
                self?.updateSelectedRoutines(routines: selectedRoutines)
            }
            .store(in: &cancellables)

        viewModel.output.nextButtonPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] canRegister in
                self?.registerButton.updateButtonState(buttonState: canRegister ? .default : .disabled)
            }
            .store(in: &cancellables)

        viewModel.output.registerRoutineResultPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] registerResult in
                if registerResult {
                    BitnagilLogger.log(logType: .debug, message: "추천 루틴 등록 완료")
                    self?.goToHomeView()
                } else {
                    BitnagilLogger.log(logType: .error, message: "추천 루틴 등록 실패")
                }
            }
            .store(in: &cancellables)
    }

    private func updateRecommendedRoutines(routines: Set<RecommendedRoutine>) {
        recommendedRoutineStackView.arrangedSubviews.forEach { view in
            recommendedRoutineStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        recommendedRoutines.removeAll()

        for routine in routines {
            let routineButton = OnboardingChoiceButton(onboardingChoice: routine)
            routineButton.tag = routine.id

            recommendedRoutines[routine.id] = routineButton
            recommendedRoutineStackView.addArrangedSubview(routineButton)
            routineButton.addAction(UIAction { [weak self] _ in
                self?.viewModel.action(input: .selectRoutine(routine: routine))
            }, for: .touchUpInside)

            routineButton.snp.makeConstraints { make in
                make.height.equalTo(Layout.routineButtonHeight)
            }
        }
    }

    private func updateSelectedRoutines(routines: Set<RecommendedRoutine>) {
        recommendedRoutines.forEach { routine in
            if routines.contains(where: { $0.id == routine.key }) {
                routine.value.updateButtonState(isChecked: true)
            } else {
                routine.value.updateButtonState(isChecked: false)
            }
        }
    }

    private func goToHomeView() {
        guard let homeViewModel = DIContainer.shared.resolve(type: HomeViewModel.self) else {
            fatalError("homeViewModel 의존성이 등록되지 않았습니다.")
        }
        let homeView = HomeViewController(viewModel: homeViewModel)
        self.navigationController?.pushViewController(homeView, animated: true)
    }
}
