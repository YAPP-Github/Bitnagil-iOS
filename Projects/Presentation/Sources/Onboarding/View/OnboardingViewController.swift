//
//  OnboardingViewController.swift
//  Presentation
//
//  Created by 최정인 on 7/8/25.
//

import Combine
import Domain
import SnapKit
import UIKit

final class OnboardingViewController: BaseViewController<OnboardingViewModel> {
    private enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let mainLabelMinTopSpacing: CGFloat = 60
        static let mainLabelMaxTopSpacing: CGFloat = 86
        static let mainLabelMinHeight: CGFloat = 30
        static let mainLabelHeight: CGFloat = 60
        static let subLabelTopSpacing: CGFloat = 10
        static let choiceButtonHeight: CGFloat = 56
        static let choiceButtonHeightWithSubLabel: CGFloat = 74
        static let choiceStackViewSpacing: CGFloat = 12
        static let choiceStackViewTopSpacing: CGFloat = 28
        static let nextButtonHeight: CGFloat = 54
        static let nextButtonBottomSpacing: CGFloat = 20
    }

    private let mainLabel = UILabel()
    private var subLabel: UILabel? = nil
    private let choiceStackView = UIStackView()
    private var choiceButtons: [OnboardingChoiceType: OnboardingChoiceButton] = [:]
    private let nextButton = PrimaryButton(buttonState: .disabled, buttonTitle: "다음")

    private let onboarding: OnboardingType
    private let isFromMypage: Bool
    private var isLayoutConfigured: Bool = false
    private var mainLabelTopConstraint: Constraint?
    private var cancellables: Set<AnyCancellable>

    init(
        viewModel: OnboardingViewModel,
        onboarding: OnboardingType,
        isFromMypage: Bool = false
    ) {
        self.onboarding = onboarding
        self.isFromMypage = isFromMypage
        cancellables = []
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.action(input: .fetchOnboardingChoice(onboarding: onboarding))
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
        mainLabel.attributedText = BitnagilFont(style: .title2, weight: .bold).attributedString(text: onboarding.mainTitle)
        mainLabel.textColor = BitnagilColor.gray10
        mainLabel.numberOfLines = 2
        if onboarding == .feeling {
            mainLabel.numberOfLines = 1
        }
        mainLabel.textAlignment = .left

        if let subTitle = onboarding.subTitle {
            subLabel = UILabel()
            if let subLabel {
                subLabel.text = subTitle
                subLabel.font = BitnagilFont(style: .body1, weight: .medium).font
                subLabel.textColor = BitnagilColor.gray50
                subLabel.textAlignment = .left
            }
        }

        choiceStackView.axis = .vertical
        choiceStackView.spacing = Layout.choiceStackViewSpacing

        for (index, choice) in onboarding.choices.enumerated() {
            let choiceButton = OnboardingChoiceButton(onboardingChoice: choice)
            choiceButton.tag = index

            choiceButton.addAction(
                UIAction { [weak self] _ in
                    self?.viewModel.action(input: .selectOnboardingChoice(selectedChoice: choice))
                },
                for: .touchUpInside)
            choiceButtons[choice] = choiceButton
            choiceStackView.addArrangedSubview(choiceButton)

            choiceButton.snp.makeConstraints { make in
                make.height.equalTo(choice.subTitle == nil ? Layout.choiceButtonHeight : Layout.choiceButtonHeightWithSubLabel)
            }
        }

        nextButton.addAction(
            UIAction { _ in
                self.goNextStep()
            },
            for: .touchUpInside)
    }

    override func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        view.backgroundColor = .systemBackground
        navigationController?.setNavigationBarHidden(true, animated: false)
        configureCustomNavigationBar(navigationBarStyle: .withProgressBar(step: onboarding.step))

        view.addSubview(mainLabel)
        view.addSubview(choiceStackView)
        view.addSubview(nextButton)

        var previousView = mainLabel
        mainLabel.snp.makeConstraints { make in
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.trailing.equalTo(safeArea).inset(Layout.horizontalMargin)
            mainLabelTopConstraint = make.top.equalTo(safeArea).offset(Layout.mainLabelMaxTopSpacing).constraint
            make.height.equalTo(onboarding == .feeling ? Layout.mainLabelMinHeight : Layout.mainLabelHeight)
        }

        if let subLabel {
            view.addSubview(subLabel)

            subLabel.snp.makeConstraints { make in
                make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
                make.trailing.equalTo(safeArea).inset(Layout.horizontalMargin)
                make.top.equalTo(mainLabel.snp.bottom).offset(Layout.subLabelTopSpacing)
            }
            previousView = subLabel
        }

        choiceStackView.snp.makeConstraints { make in
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.trailing.equalTo(safeArea).inset(Layout.horizontalMargin)
            make.top.equalTo(previousView.snp.bottom).offset(Layout.choiceStackViewTopSpacing)
        }

        nextButton.snp.makeConstraints { make in
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.trailing.equalTo(safeArea).inset(Layout.horizontalMargin)
            make.bottom.equalTo(safeArea).inset(Layout.nextButtonBottomSpacing)
            make.height.equalTo(Layout.nextButtonHeight)
        }
    }

    override func bind() {
        viewModel.output.timeOnboardingChoicePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] timeChoice in
                self?.updateOnboardingChoice(onboardingChoice: timeChoice)
            }
            .store(in: &cancellables)

        viewModel.output.frequencyOnboardingChoicePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] frequencyChoice in
                self?.updateOnboardingChoice(onboardingChoice: frequencyChoice)
            }
            .store(in: &cancellables)

        viewModel.output.feelingOnboardingChoicePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] feelingChoices in
                self?.updateOnboardingChoices(onboardingChoices: feelingChoices)
            }
            .store(in: &cancellables)

        viewModel.output.outdoorOnboardingChoicePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] outdoorChoice in
                self?.updateOnboardingChoice(onboardingChoice: outdoorChoice)
            }
            .store(in: &cancellables)

        viewModel.output.nextButtonPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] canGoNext in
                self?.nextButton.updateButtonState(buttonState: canGoNext ? .default : .disabled)
            }
            .store(in: &cancellables)
    }

    private func updateOnboardingChoice(onboardingChoice: OnboardingChoiceType?) {
        choiceButtons.forEach { choice in
            if choice.key == onboardingChoice {
                choice.value.updateButtonState(isChecked: true)
            } else {
                choice.value.updateButtonState(isChecked: false)
            }
        }
    }

    private func updateOnboardingChoices(onboardingChoices: Set<OnboardingChoiceType>) {
        choiceButtons.forEach { choice in
            if onboardingChoices.contains(choice.key) {
                choice.value.updateButtonState(isChecked: true)
            } else {
                choice.value.updateButtonState(isChecked: false)
            }
        }
    }

    private func goNextStep() {
        var nextStep: OnboardingType?
        switch onboarding {
        case .time:
            nextStep = .feeling
        case .feeling:
            nextStep = .frequency
        case .frequency:
            nextStep = .outdoor
        case .outdoor:
            nextStep = nil
        }

        var nextView: UIViewController?
        if let nextStep {
            nextView = OnboardingViewController(
                viewModel: viewModel,
                onboarding: nextStep,
                isFromMypage: isFromMypage)
        } else {
            nextView = OnboardingResultViewController(viewModel: viewModel, isFromMypage: isFromMypage)
        }
        guard let nextView else { return }
        self.navigationController?.pushViewController(nextView, animated: true)
    }
}
