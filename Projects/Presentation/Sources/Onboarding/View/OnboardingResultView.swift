//
//  OnboardingResultView.swift
//  Presentation
//
//  Created by 최정인 on 7/10/25.
//

import Combine
import Domain
import Shared
import SnapKit
import UIKit

final class OnboardingResultView: BaseViewController<OnboardingViewModel> {

    private enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let mainLabelMinTopSpacing: CGFloat = 12
        static let mainLabelMaxTopSpacing: CGFloat = 32
        static let mainLabelHeight: CGFloat = 60
        static let subLabelTopSpacing: CGFloat = 10
        static let subLabelHeight: CGFloat = 20
        static let resultStackViewTopSpacing: CGFloat = 4
        static let resultStackViewSpacing: CGFloat = 2
        static let graphicTopSpacing: CGFloat = 80
        static let graphicWidth: CGFloat = 306
        static let graphicHeight: CGFloat = 290
    }

    private let mainLabel = UILabel()
    private let resultStackView = UIStackView()
    private let subLabel = UILabel()
    private var timeResultLabel = UILabel()
    private var feelingResultLabel = UILabel()
    private var outdoorResultLabel = UILabel()
    private let graphicView = UIImageView()

    private var isLayoutConfigured: Bool = false
    private var mainLabelTopConstraint: Constraint?

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
        viewModel.action(input: .makeOnboardingResult)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animate(withDuration: 0.5, delay: 2, options: .curveEaseInOut, animations: {
            self.view.alpha = 0.0
        }, completion: { [weak self] finshed in
            self?.viewModel.action(input: .fetchOnboardingChoices)
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let stepCount = OnboardingType.allCases.count + 1
        configureNavigationBar(navigationStyle: .withPrograssBar(step: stepCount, stepCount: stepCount))
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
        let text = "이제 당신에게\n꼭 맞는 루틴을 제안해드릴게요."
        mainLabel.attributedText = BitnagilFont(style: .title2, weight: .bold).attributedString(text: text)
        mainLabel.textColor = BitnagilColor.navy500
        mainLabel.numberOfLines = 2
        mainLabel.textAlignment = .left
        
        subLabel.text = "당신은 지금"
        subLabel.font = BitnagilFont(style: .body2, weight: .medium).font
        subLabel.textColor = BitnagilColor.gray30

        resultStackView.axis = .vertical
        resultStackView.spacing = Layout.resultStackViewSpacing

        [timeResultLabel, feelingResultLabel, outdoorResultLabel].forEach { label in
            label.textColor = BitnagilColor.gray30
        }

        graphicView.image = BitnagilGraphic.onboardingGraphic
    }

    override func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        view.backgroundColor = BitnagilColor.gray99

        view.addSubview(mainLabel)
        view.addSubview(subLabel)
        view.addSubview(resultStackView)
        resultStackView.addArrangedSubview(timeResultLabel)
        resultStackView.addArrangedSubview(feelingResultLabel)
        resultStackView.addArrangedSubview(outdoorResultLabel)
        view.addSubview(graphicView)

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

        resultStackView.snp.makeConstraints { make in
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.trailing.equalTo(safeArea).inset(Layout.horizontalMargin)
            make.top.equalTo(subLabel.snp.bottom).offset(Layout.resultStackViewTopSpacing)
        }

        [timeResultLabel, feelingResultLabel, outdoorResultLabel].forEach { label in
            label.snp.makeConstraints { make in
                make.height.equalTo(Layout.subLabelHeight)
            }
        }

        graphicView.snp.makeConstraints { make in
            make.top.equalTo(resultStackView.snp.bottom).offset(Layout.graphicTopSpacing)
            make.centerX.equalToSuperview()
            make.width.equalTo(Layout.graphicWidth)
            make.height.equalTo(Layout.graphicHeight)
        }
    }

    override func bind() {
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

        updateTimeResultLabel(timeResult: timeResult)
        updateFeelingResultLabel(feelingResult: feelingResult)
        updateOutdoorResultLabel(outdoorResult: outdoorResult)
    }

    private func updateTimeResultLabel(timeResult: String) {
        let baseText: String

        switch timeResult {
        case "아침루틴":
            baseText = "• 아침루틴을 만들고 싶고"
        case "저녁루틴":
            baseText = "• 저녁루틴을 만들고 싶고"
        case "전체루틴":
            baseText = "• 전체루틴을 회복하고 싶고"
        default:
            baseText = ""
        }

        timeResultLabel.attributedText = NSAttributedString.highlighted(text: baseText, highlightText: timeResult)
    }

    private func updateFeelingResultLabel(feelingResult: String) {
        let baseText = "• \(feelingResult)을 원하는 중이에요"
        feelingResultLabel.attributedText = NSAttributedString.highlighted(text: baseText, highlightText: feelingResult)
    }

    private func updateOutdoorResultLabel(outdoorResult: String) {
        let baseText = "• \(outdoorResult)을 목표로 해볼게요!"
        outdoorResultLabel.attributedText = NSAttributedString.highlighted(text: baseText, highlightText: outdoorResult)
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
