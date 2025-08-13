//
//  OnboardingResultViewController.swift
//  Presentation
//
//  Created by 최정인 on 7/10/25.
//

import Combine
import Domain
import Shared
import SnapKit
import UIKit

final class OnboardingResultViewController: BaseViewController<OnboardingViewModel> {
    private enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let mainLabelMinTopSpacing: CGFloat = 60
        static let mainLabelMaxTopSpacing: CGFloat = 83
        static let mainLabelHeight: CGFloat = 60
        static let resultGraphicViewTopMinSpacing: CGFloat = 13
        static let resultGraphicViewTopSpacing: CGFloat = 28
        static let resultGraphicViewWidth: CGFloat = 311
        static let resultGraphicViewHeight: CGFloat = 151
        static let rectangleImageViewTopSpacing: CGFloat = 1.5
        static let rectangleImageViewWidth: CGFloat = 310
        static let rectangleImageViewHeight: CGFloat = 220
        static let rectangleImageViewMaxHeight: CGFloat = 260
        static let nameLabelTopSpacing: CGFloat = 30
        static let nameLabelLeadingSpacing: CGFloat = 30
        static let nameLabelHeight: CGFloat = 25.76
        static let resultStackViewSpacing: CGFloat = 12
        static let resultStackViewTopSpacing: CGFloat = 13
        static let resultStackViewWidth: CGFloat = 250
        static let resultLabelHeight: CGFloat = 31
        static let resultLabelMaxHeight: CGFloat = 68
        static let nextButtonBottomSpacing: CGFloat = 20
        static let nextButtonHeight: CGFloat = 54
    }

    private let mainLabel = UILabel()
    private let resultGraphicView = UIImageView()
    private let rectangleImageView = UIImageView()
    private let nameLabel = UILabel()
    private let resultStackView = UIStackView()
    private let nextButton = PrimaryButton(buttonState: .default, buttonTitle: "다음")

    private var isLayoutConfigured: Bool = false
    private var mainLabelTopConstraint: Constraint?
    private var resultGraphicViewTopConstraint: Constraint?
    private var rectangleHeightConstraint: Constraint?

    private let isFromMypage: Bool
    private var cancellables: Set<AnyCancellable>
    init(viewModel: OnboardingViewModel, isFromMypage: Bool = false) {
        self.isFromMypage = isFromMypage
        cancellables = []
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.action(input: .loadNickname)
        viewModel.action(input: .makeOnboardingResult)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        let text = "이제 포모가 당신에게\n꼭 맞는 루틴을 찾아줄거예요."
        mainLabel.attributedText = BitnagilFont(style: .title2, weight: .bold).attributedString(text: text)
        mainLabel.textColor = BitnagilColor.gray10
        mainLabel.numberOfLines = 2
        mainLabel.textAlignment = .left

        resultGraphicView.image = BitnagilGraphic.onboardingFomoGraphic
        rectangleImageView.image = BitnagilGraphic.onboardingRectangle

        nameLabel.text = "님은 ..."
        nameLabel.font = BitnagilFont(style: .title3, weight: .semiBold).font
        nameLabel.textColor = BitnagilColor.gray10

        resultStackView.axis = .vertical
        resultStackView.spacing = Layout.resultStackViewSpacing

        nextButton.addAction(
            UIAction { [weak self] _ in
                self?.viewModel.action(input: .fetchOnboardingChoices)
            }, for: .touchUpInside)
    }

    override func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        view.backgroundColor = .systemBackground
        navigationController?.setNavigationBarHidden(true, animated: false)
        configureCustomNavigationBar(navigationBarStyle: .withProgressBar(step: OnboardingType.allCases.count + 1))

        view.addSubview(mainLabel)
        view.addSubview(resultGraphicView)
        view.addSubview(rectangleImageView)
        view.addSubview(nameLabel)
        view.addSubview(resultStackView)
        view.addSubview(nextButton)

        mainLabel.snp.makeConstraints { make in
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            mainLabelTopConstraint = make.top.equalTo(safeArea).offset(Layout.mainLabelMinTopSpacing).constraint
            make.height.equalTo(Layout.mainLabelHeight)
        }

        resultGraphicView.snp.makeConstraints { make in
            resultGraphicViewTopConstraint = make.top.equalTo(mainLabel.snp.bottom).offset(Layout.resultGraphicViewTopSpacing).constraint
            make.centerX.equalToSuperview()
            make.width.equalTo(Layout.resultGraphicViewWidth)
            make.height.equalTo(Layout.resultGraphicViewHeight)
        }

        rectangleImageView.snp.makeConstraints { make in
            make.top.equalTo(resultGraphicView.snp.bottom).offset(-Layout.rectangleImageViewTopSpacing)
            make.centerX.equalToSuperview()
            make.width.equalTo(Layout.rectangleImageViewWidth)
            rectangleHeightConstraint = make.height.equalTo(Layout.rectangleImageViewHeight).constraint
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(rectangleImageView).offset(Layout.nameLabelTopSpacing)
            make.leading.equalTo(rectangleImageView).offset(Layout.nameLabelLeadingSpacing)
            make.height.equalTo(Layout.nameLabelHeight)
        }

        resultStackView.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(Layout.resultStackViewTopSpacing)
            make.leading.equalTo(nameLabel)
            make.width.equalTo(Layout.resultStackViewWidth)
        }

        nextButton.snp.makeConstraints { make in
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.trailing.equalTo(safeArea).inset(Layout.horizontalMargin)
            make.bottom.equalTo(safeArea).inset(Layout.nextButtonBottomSpacing)
            make.height.equalTo(Layout.nextButtonHeight)
        }
    }

    override func bind() {
        viewModel.output.nicknamePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] nickname in
                self?.nameLabel.text = "\(nickname)님은 ..."
            }
            .store(in: &cancellables)

        viewModel.output.onboardingResultPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] onboardingResults in
                self?.updateResultLabels(results: onboardingResults)
            }
            .store(in: &cancellables)

        viewModel.output.onboardingChoicesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] onboardingChoices in
                self?.goToResultRecommendedRoutineView(onboardingChoices: onboardingChoices)
            }
            .store(in: &cancellables)
    }

    private func updateResultLabels(results: [String]) {
        guard results.count == 3 else { return }
        let timeResult = results[0]
        let feelingResult = results[1]
        let outdoorResult = results[2]

        resultStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }

        let timeResultView = OnboardingResultSummaryView(onboardingType: .time, highlightText: timeResult)
        let outdoorResultView = OnboardingResultSummaryView(onboardingType: .outdoor, highlightText: outdoorResult)

        let feelingResultStackView = UIStackView()
        feelingResultStackView.axis = .vertical
        feelingResultStackView.spacing = 6

        let feelingResultView = OnboardingResultSummaryView(onboardingType: .feeling, highlightText: feelingResult)
        feelingResultStackView.addArrangedSubview(feelingResultView)

        let ifNeedExpandFeelingResult = feelingResult.filter({ $0 == "," }).count >= 2
        if ifNeedExpandFeelingResult {
            let extendtedFeelingResultView = OnboardingResultSummaryView(onboardingType: nil, highlightText: "")
            feelingResultStackView.addArrangedSubview(extendtedFeelingResultView)
            extendtedFeelingResultView.snp.makeConstraints { make in
                make.height.equalTo(Layout.resultLabelHeight)
            }
            rectangleImageView.image = BitnagilGraphic.onboardingBigRectangle
            rectangleHeightConstraint?.update(offset: Layout.rectangleImageViewMaxHeight)
            resultGraphicViewTopConstraint?.update(offset: Layout.resultGraphicViewTopMinSpacing)
        }
        feelingResultStackView.snp.makeConstraints { make in
            make.height.equalTo(ifNeedExpandFeelingResult ? Layout.resultLabelMaxHeight : Layout.resultLabelHeight)
        }

        [timeResultView, feelingResultView, outdoorResultView].forEach {
            $0.snp.makeConstraints { make in
                make.height.equalTo(Layout.resultLabelHeight)
            }
        }

        [timeResultView, feelingResultStackView, outdoorResultView].forEach {
            resultStackView.addArrangedSubview($0)
        }
    }

    private func goToResultRecommendedRoutineView(onboardingChoices: [OnboardingChoiceType]) {
        guard let resultRecommendedRoutineViewModel = DIContainer.shared.resolve(type: ResultRecommendedRoutineViewModel.self)
        else{ fatalError("resultRecommendedRoutineViewModel 의존성이 등록되지 않았습니다.") }

        var resultRecommendedView: ResultRecommendedRoutineView
        if isFromMypage {
            resultRecommendedRoutineViewModel.configure(viewModelType: .mypage(onboardingChoices: onboardingChoices))
            resultRecommendedView = ResultRecommendedRoutineView(entryPoint: .mypage, viewModel: resultRecommendedRoutineViewModel)
        } else {
            resultRecommendedRoutineViewModel.configure(viewModelType: .onboarding(onboardingChoices: onboardingChoices))
            resultRecommendedView = ResultRecommendedRoutineView(entryPoint: .onboarding, viewModel: resultRecommendedRoutineViewModel)
        }
        self.navigationController?.pushViewController(resultRecommendedView, animated: true)
    }
}
