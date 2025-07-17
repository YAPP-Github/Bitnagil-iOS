//
//  OnboardingResultView.swift
//  Presentation
//
//  Created by 최정인 on 7/10/25.
//

import Combine
import Domain
import UIKit

final class OnboardingResultView: BaseViewController<OnboardingViewModel> {

    private enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let mainLabelHeight: CGFloat = 60
        static let subLabelTopSpacing: CGFloat = 10
        static let subLabelHeight: CGFloat = 20
        static let resultStackViewTopSpacing: CGFloat = 4
        static let resultStackViewSpacing: CGFloat = 2
        static let graphicTopSpacing: CGFloat = 36
        static let graphicBotttomSpacing: CGFloat = 20

        static var mainLabelTopSpacing: CGFloat {
            let height = UIScreen.main.bounds.height
            if height <= 667 { return 12 }
            else { return 32 }
        }
    }

    private let mainLabel = UILabel()
    private let resultStackView = UIStackView()
    private let subLabel = UILabel()
    private var timeResultLabel = UILabel()
    private var feelingResultLabel = UILabel()
    private var outdoorResultLabel = UILabel()
    private let graphicView = UIView()
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
        viewModel.action(input: .makeOnboardingResult)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animate(withDuration: 0.5, delay: 3, options: .curveEaseInOut, animations: {
            self.view.alpha = 0.0
        }, completion: { [weak self] finished in
            guard let self else { return }
            let recommendedRoutineView = OnboardingRecommendedRoutineView(viewModel: self.viewModel)
            self.navigationController?.pushViewController(recommendedRoutineView, animated: true)
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let stepCount = OnboardingType.allCases.count + 1
        configureNavigationBar(navigationStyle: .withPrograssBar(step: stepCount, stepCount: stepCount))
    }

    override func configureAttribute() {
        mainLabel.do {
            let text = "이제 당신에게\n꼭 맞는 루틴을 제안해드릴게요."
            $0.attributedText = BitnagilFont(style: .title2, weight: .bold).attributedString(text: text)
            $0.textColor = BitnagilColor.navy500
            $0.numberOfLines = 2
            $0.textAlignment = .left
        }

        subLabel.do {
            $0.text = "당신은 지금"
            $0.font = BitnagilFont(style: .body2, weight: .medium).font
            $0.textColor = BitnagilColor.gray30
        }

        resultStackView.do {
            $0.axis = .vertical
            $0.spacing = Layout.resultStackViewSpacing
        }

        [timeResultLabel, feelingResultLabel, outdoorResultLabel].forEach { label in
            label.do {
                $0.textColor = BitnagilColor.gray30
            }
        }
        graphicView.do {
            $0.backgroundColor = BitnagilColor.gray90
        }
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
            make.top.equalTo(safeArea).offset(Layout.mainLabelTopSpacing)
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
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.trailing.equalTo(safeArea).inset(Layout.horizontalMargin)
            make.top.equalTo(resultStackView.snp.bottom).offset(Layout.graphicTopSpacing)
            make.bottom.equalTo(safeArea).inset(Layout.graphicBotttomSpacing)
        }
    }

    override func bind() {
        viewModel.output.onboardingResultPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] onboardingResults in
                self?.updateResultLabels(results: onboardingResults)
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

        timeResultLabel.do {
            $0.attributedText = NSAttributedString.highlighted(text: baseText, highlightText: timeResult)
        }
    }

    private func updateFeelingResultLabel(feelingResult: String) {
        let baseText = "• \(feelingResult)을 원하는 중이에요"
        feelingResultLabel.do {
            $0.attributedText = NSAttributedString.highlighted(text: baseText, highlightText: feelingResult)
        }
    }

    private func updateOutdoorResultLabel(outdoorResult: String) {
        let baseText = "• \(outdoorResult)을 목표로 해볼게요!"
        outdoorResultLabel.do {
            $0.attributedText = NSAttributedString.highlighted(text: baseText, highlightText: outdoorResult)
        }
    }
}
