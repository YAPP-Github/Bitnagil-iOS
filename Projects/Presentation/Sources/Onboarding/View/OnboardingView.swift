//
//  OnboardingView.swift
//  Presentation
//
//  Created by 최정인 on 7/8/25.
//

import Combine
import Domain
import UIKit

final class OnboardingView: BaseViewController<OnboardingViewModel> {

    private enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let mainLabelHeight: CGFloat = 60
        static let subLabelTopSpacing: CGFloat = 10
        static let choiceButtonHeight: CGFloat = 52
        static let choiceButtonHeightWithSubLabel: CGFloat = 84
        static let choiceStackViewSpacing: CGFloat = 12
        static let choiceStackViewTopSpacing: CGFloat = 28
        static let nextButtonHeight: CGFloat = 54
        static let nextButtonBottomSpacing: CGFloat = 20

        static var mainLabelTopSpacing: CGFloat {
            let height = UIScreen.main.bounds.height
            if height <= 667 { return 12 }
            else { return 32 }
        }
    }

    private let onboarding: OnboardingType
    private let mainLabel = UILabel()
    private var subLabel: UILabel? = nil
    private let choiceStackView = UIStackView()
    private var choiceButtons: [OnboardingChoiceType: OnboardingChoiceButton] = [:]
    private let nextButton = PrimaryButton(buttonState: .disabled, buttonTitle: "다음")
    private var cancellables: Set<AnyCancellable>

    init(viewModel: OnboardingViewModel, onboarding: OnboardingType) {
        self.onboarding = onboarding
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

        let stepCount = OnboardingType.allCases.count + 1
        configureNavigationBar(navigationStyle: .withPrograssBar(step: onboarding.step, stepCount: stepCount))

        self.viewModel.action(input: .fetchOnboardingChoice(onboarding: onboarding))
    }

    override func configureAttribute() {
        mainLabel.attributedText = BitnagilFont(style: .title2, weight: .bold).attributedString(text: onboarding.mainTitle)
        mainLabel.textColor = BitnagilColor.navy500
        mainLabel.numberOfLines = 2
        mainLabel.textAlignment = .left

        if let subTitle = onboarding.subTitle {
            subLabel = UILabel()
            if let subLabel {
                subLabel.attributedText = BitnagilFont(style: .body2, weight: .medium).attributedString(text: subTitle)
                subLabel.textColor = BitnagilColor.gray50
                subLabel.numberOfLines = 2
                subLabel.textAlignment = .left
            }
        }

        choiceStackView.axis = .vertical
        choiceStackView.spacing = Layout.choiceStackViewSpacing

        for (index, choice) in onboarding.choices.enumerated() {
            let choiceButton = OnboardingChoiceButton(onboardingChoice: choice)
            choiceButton.tag = index

            choiceButton.addAction(UIAction { [weak self] _ in
                self?.viewModel.action(input: .selectOnboardingChoice(selectedChoice: choice))
            }, for: .touchUpInside)
            choiceButtons[choice] = choiceButton
            choiceStackView.addArrangedSubview(choiceButton)

            choiceButton.snp.makeConstraints { make in
                make.height.equalTo(choice.subTitle == nil ? Layout.choiceButtonHeight : Layout.choiceButtonHeightWithSubLabel)
            }
        }

        nextButton.addAction(UIAction { _ in
            self.goNextStep()
        }, for: .touchUpInside)
    }

    override func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        view.backgroundColor = BitnagilColor.gray99

        view.addSubview(mainLabel)
        view.addSubview(choiceStackView)
        view.addSubview(nextButton)

        var previousView = mainLabel
        mainLabel.snp.makeConstraints { make in
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.trailing.equalTo(safeArea).inset(Layout.horizontalMargin)
            make.top.equalTo(safeArea).offset(Layout.mainLabelTopSpacing)
            make.height.equalTo(Layout.mainLabelHeight)
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
            nextStep = .frequency
        case .frequency:
            nextStep = .feeling
        case .feeling:
            nextStep = .outdoor
        case .outdoor:
            nextStep = nil
        }

        var nextView: UIViewController?
        if let nextStep {
            nextView = OnboardingView(viewModel: viewModel, onboarding: nextStep)
        } else {
            nextView = OnboardingResultView(viewModel: viewModel)
        }
        guard let nextView else { return }
        self.navigationController?.pushViewController(nextView, animated: true)
    }
}
