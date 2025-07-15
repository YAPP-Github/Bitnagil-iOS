//
//  RecommendedRoutineView.swift
//  Presentation
//
//  Created by 최정인 on 7/11/25.
//

import UIKit
import Combine

final class RecommendedRoutineView: BaseViewController<OnboardingViewModel> {

    private enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let mainLabelHeight: CGFloat = 60
        static let subLabelTopSpacing: CGFloat = 10
        static let subLabelHeight: CGFloat = 40
        static let routineStackViewSpacing: CGFloat = 12
        static let routineStackViewTopSpacing: CGFloat = 28
        static let routineButtonHeight: CGFloat = 84
        static let registerButtonHeight: CGFloat = 54
        static let registerButtonBottomSpacing: CGFloat = 20

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
        viewModel.action(input: .fetchRecommendedRoutine)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

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
    }

    override func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        view.backgroundColor = BitnagilColor.gray99

        view.addSubview(mainLabel)
        view.addSubview(subLabel)
        view.addSubview(recommendedRoutineStackView)
        view.addSubview(registerButton)

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
            make.bottom.equalTo(safeArea).inset(Layout.registerButtonBottomSpacing)
            make.height.equalTo(Layout.registerButtonHeight)
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
}
