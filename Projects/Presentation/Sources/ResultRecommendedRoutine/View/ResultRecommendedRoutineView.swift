//
//  ResultRecommendedRoutineView.swift
//  Presentation
//
//  Created by 최정인 on 7/28/25.
//

import Combine
import Domain
import Shared
import SnapKit
import UIKit

final class ResultRecommendedRoutineView: BaseViewController<ResultRecommendedRoutineViewModel> {

    enum EntryPoint {
        case onboarding
        case mypage
        case emotion

        var mainLabelText: String {
            switch self {
            case .onboarding, .mypage:
                "당신만의 추천 루틴이\n생성되었어요!"
            case .emotion:
                "오늘 감정에 따른\n루틴을 추천드릴게요!"
            }
        }

        var subLabelText: String {
            switch self {
            case .onboarding:
                "원하는 루틴을 선택해서 가볍게 시작해보세요.\n선택한 루틴은 홈화면에서 자유롭게 수정 할 수 있어요."
            case .mypage:
                "생활 패턴과 목표에 맞춰 다시 구성된 맞춤 루틴이에요.\n원하는 루틴을 선택해서 가볍게 시작해보세요."
            case .emotion:
                "오늘 당신의 감정 상태에 맞춰 구성된 맞춤 루틴이에요.\n원하는 루틴을 선택해서 가볍게 시작해보세요."
            }
        }

        var confirmButtonLabel: String {
            switch self {
            case .onboarding: "등록하기"
            case .mypage: "확인"
            case .emotion: "루틴 등록하기"
            }
        }

        var isHiddenSkipButton: Bool {
            switch self {
            case .onboarding, .emotion:
                return false
            case .mypage:
                return true
            }
        }

        var isRoutineButtonEnabled: Bool {
            switch self {
            case .onboarding, .emotion:
                true
            case .mypage:
                false
            }
        }
    }

    private enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let mainLabelMinTopSpacing: CGFloat = 12
        static let mainLabelMaxTopSpacing: CGFloat = 32
        static let mainLabelHeight: CGFloat = 60
        static let subLabelTopSpacing: CGFloat = 10
        static let subLabelHeight: CGFloat = 40
        static let routineStackViewSpacing: CGFloat = 12
        static let routineStackViewTopSpacing: CGFloat = 28
        static let routineButtonHeight: CGFloat = 84
        static let confirmButtonHeight: CGFloat = 54
        static let confirmButtonBottomSpacing: CGFloat = 10
        static let skipButtonLabelFontSize: CGFloat = 14
        static let skipButtonLabelLineHeight: CGFloat = 20
        static let skipButtonHeight: CGFloat = 54
        static let skipButtonBottomSpacing: CGFloat = 20
    }

    private let mainLabel = UILabel()
    private var subLabel = UILabel()
    private let recommendedRoutineStackView = UIStackView()
    private var recommendedRoutines: [Int: OnboardingChoiceButton] = [:]
    private var confirmButton = PrimaryButton(buttonState: .disabled, buttonTitle: "등록하기")
    private let skipButtonLabel = UILabel()
    private let skipButton = UIButton()

    private var isLayoutConfigured: Bool = false
    private var mainLabelTopConstraint: Constraint?

    private var cancellables: Set<AnyCancellable>
    private let entryPoint: EntryPoint
    init(entryPoint: EntryPoint, viewModel: ResultRecommendedRoutineViewModel) {
        self.entryPoint = entryPoint
        cancellables = []
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.action(input: .fetchResultRecommendedRoutines)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        settingNavigationItem()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !isLayoutConfigured {
            updateMainLabelTopSpacing()
            isLayoutConfigured = true
        }
    }

    private func updateMainLabelTopSpacing() {
        let height = view.bounds.height
        let spacing: CGFloat = height <= 667 ? Layout.mainLabelMinTopSpacing : Layout.mainLabelMaxTopSpacing

        mainLabelTopConstraint?.update(offset: spacing)
    }

    override func configureAttribute() {
        let mainLabelText = entryPoint.mainLabelText
        mainLabel.attributedText = BitnagilFont(style: .title2, weight: .bold).attributedString(text: mainLabelText)
        mainLabel.textColor = BitnagilColor.navy500
        mainLabel.numberOfLines = 2
        mainLabel.textAlignment = .left

        let subLabelText = entryPoint.subLabelText
        subLabel.attributedText = BitnagilFont(style: .body2, weight: .medium).attributedString(text: subLabelText)
        subLabel.textColor = BitnagilColor.gray50
        subLabel.numberOfLines = 2
        subLabel.textAlignment = .left

        recommendedRoutineStackView.axis = .vertical
        recommendedRoutineStackView.spacing = Layout.routineStackViewSpacing

        configureEntryPoint()
        configureConfirmButton()

        skipButtonLabel.attributedText = BitnagilFont(
            fontSize: Layout.skipButtonLabelFontSize,
            lineHeight: Layout.skipButtonLabelLineHeight,
            underline: true,
            weight: .regular
        ).attributedString(text: "건너뛰기")
        skipButtonLabel.textColor = BitnagilColor.navy500

        skipButton.isHidden = entryPoint.isHiddenSkipButton
        configureSkipButton()
    }

    override func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        view.backgroundColor = BitnagilColor.gray99

        view.addSubview(mainLabel)
        view.addSubview(subLabel)
        view.addSubview(recommendedRoutineStackView)
        view.addSubview(confirmButton)
        skipButton.addSubview(skipButtonLabel)
        view.addSubview(skipButton)

        mainLabel.snp.makeConstraints { make in
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.trailing.equalTo(safeArea).inset(Layout.horizontalMargin)
            mainLabelTopConstraint = make.top.equalTo(safeArea).offset(Layout.mainLabelMinTopSpacing).constraint
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

        confirmButton.snp.makeConstraints { make in
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.trailing.equalTo(safeArea).inset(Layout.horizontalMargin)
            if entryPoint.isHiddenSkipButton {
                make.bottom.equalTo(safeArea).inset(20)
            } else {
                make.bottom.equalTo(skipButton.snp.top).offset(-Layout.confirmButtonBottomSpacing)
            }
            make.height.equalTo(Layout.confirmButtonHeight)
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

    private func configureEntryPoint() {
        switch entryPoint {
        case .onboarding:
            confirmButton = PrimaryButton(buttonState: .disabled, buttonTitle: entryPoint.confirmButtonLabel)
        case .mypage:
            confirmButton = PrimaryButton(buttonState: .default, buttonTitle: entryPoint.confirmButtonLabel)
        case .emotion:
            confirmButton = PrimaryButton(buttonState: .disabled, buttonTitle: entryPoint.confirmButtonLabel)
        }
    }

    override func bind() {
        viewModel.output.resultRecommendedRoutinesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] resultRecommendedRoutines in
                self?.updateRecommendedRoutineViews(routines: resultRecommendedRoutines)
            }
            .store(in: &cancellables)

        viewModel.output.selectedRecommendedRoutinePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedRoutines in
                self?.updateSelectedRoutines(routines: selectedRoutines)
            }
            .store(in: &cancellables)

        viewModel.output.confirmButtonPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] canGoNextView in
                self?.confirmButton.updateButtonState(buttonState: canGoNextView ? .default : .disabled)
            }
            .store(in: &cancellables)

        viewModel.output.registerRoutineResultPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] registerResult in
                if registerResult {
                    BitnagilLogger.log(logType: .debug, message: "추천 루틴 등록 완료")
                    self?.goToNextView()
                } else {
                    BitnagilLogger.log(logType: .error, message: "추천 루틴 등록 실패")
                }
            }
            .store(in: &cancellables)

        viewModel.output.selectedRoutineIdPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] routineId in
                guard let routineId else { return }
                self?.goToRoutineCreationView(routineId: routineId)
            }
            .store(in: &cancellables)
    }

    // 추천 루틴 뷰들을 업데이트합니다.
    private func updateRecommendedRoutineViews(routines: [RecommendedRoutine]) {
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
                self?.viewModel.action(input: .selectRecommendedRoutine(routine: routine))
            }, for: .touchUpInside)
            routineButton.isEnabled = entryPoint.isRoutineButtonEnabled
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

    private func settingNavigationItem() {
        switch entryPoint {
        case .onboarding, .mypage:
            let stepCount = OnboardingType.allCases.count + 1
            configureNavigationBar(navigationStyle: .withPrograssBarWithCustomBackButton(step: stepCount, stepCount: stepCount))
        case .emotion:
            configureNavigationBar(navigationStyle: .withBackButton(title: ""))
        }
    }

    private func configureConfirmButton() {
        confirmButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            switch self.entryPoint {
            case .onboarding, .emotion:
                self.viewModel.action(input: .registerRecommendedRoutine)
            case .mypage:
                self.goToNextView()
            }
        }, for: .touchUpInside)
    }

    private func configureSkipButton() {
        skipButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            switch entryPoint {
            case .emotion:
                if let navigationController = self.navigationController {
                    let viewControllers = navigationController.viewControllers
                    if viewControllers.count >= 3 {
                        navigationController.popToViewController(viewControllers[viewControllers.count - 3], animated: false)
                    }
                }
            case .onboarding, .mypage:
                goToNextView()
            }
        }, for: .touchUpInside)
    }

    private func goToNextView() {
        switch entryPoint {
        case .onboarding:
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                window.rootViewController = TabBarView()
            }
        case .mypage:
            if
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let window = windowScene.windows.first(where: { $0.isKeyWindow }),
                let tabBarView = window.rootViewController as? TabBarView {
                self.navigationController?.popToRootViewController(animated: false)
                tabBarView.selectedIndex = 2
            }
        case .emotion:
            viewModel.action(input: .fetchSelectedRoutineId)
        }
    }

    private func goToRoutineCreationView(routineId: Int) {
        guard let routineCreationViewModel = DIContainer.shared.resolve(type: RoutineCreationViewModel.self)
        else { fatalError("routineCreationViewModel 의존성이 등록되지 않았습니다.") }
        let routineCreationView = RoutineCreationView(viewModel: routineCreationViewModel, recommendRoutineId: routineId)
        self.navigationController?.pushViewController(routineCreationView, animated: true)
    }
}
