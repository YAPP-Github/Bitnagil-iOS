//
//  TermsAgreementView.swift
//  Presentation
//
//  Created by 최정인 on 7/7/25.
//

import UIKit
import Combine
import Domain
import Shared
import SnapKit
import Then
import SafariServices

final class TermsAgreementView: BaseViewController<LoginViewModel> {

    private enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let labelTopSpacing: CGFloat = 32
        static let totalButtonTopSpacing: CGFloat = 28
        static let totalButtonHeight: CGFloat = 52
        static let agreementViewTopSpacing: CGFloat = 8
        static let agreementViewHeight: CGFloat = 40
        static let startButtonBottomSpacing: CGFloat = 20
        static let startButtonHeight: CGFloat = 54
    }

    private let agreementLabel = UILabel()
    private let totalAgreementButton = TotalAgreementButton()
    private var agreementViews: [TermsType: TermsAgreementItemView] = [:]
    private let startButton = PrimaryButton(buttonState: .disabled, buttonTitle: "시작하기")
    private var cancellables: Set<AnyCancellable>

    override init(viewModel: LoginViewModel) {
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
        configureNavigationBar(navigationStyle: .withBackButton(title: "약관 동의"))
    }

    override func configureAttribute() {
        agreementLabel.do {
            let text = "빛나길 이용을 위해\n필수 약관에 동의해 주세요."
            $0.attributedText = BitnagilFont(style: .title2, weight: .bold).attributedString(text: text)
            $0.textAlignment = .left
            $0.numberOfLines = 2
            $0.textColor = BitnagilColor.navy500
        }

        totalAgreementButton.addAction(UIAction { [weak self] _ in
            self?.viewModel.action(input: .toggleTotalAgreement)
        }, for: .touchUpInside)

        startButton.addAction(UIAction { [weak self] _ in
            self?.viewModel.action(input: .submitAgreement)
        }, for: .touchUpInside)
    }

    override func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        view.backgroundColor = .systemBackground

        view.addSubview(agreementLabel)
        view.addSubview(totalAgreementButton)
        view.addSubview(startButton)

        agreementLabel.snp.makeConstraints { make in
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.top.equalTo(safeArea).offset(Layout.labelTopSpacing)
        }

        totalAgreementButton.snp.makeConstraints { make in
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.trailing.equalTo(safeArea).inset(Layout.horizontalMargin)
            make.top.equalTo(agreementLabel.snp.bottom).offset(Layout.totalButtonTopSpacing)
            make.height.equalTo(Layout.totalButtonHeight)
        }

        var previousView: UIView = totalAgreementButton
        TermsType.allCases.forEach { type in
            let agreementView = TermsAgreementItemView(termType: type)
            agreementViews[type] = agreementView
            agreementView.delegate = self

            view.addSubview(agreementView)
            agreementView.snp.makeConstraints { make in
                make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
                make.trailing.equalTo(safeArea).inset(Layout.horizontalMargin)
                if type == .service {
                    make.top.equalTo(previousView.snp.bottom).offset(Layout.agreementViewTopSpacing)
                } else {
                    make.top.equalTo(previousView.snp.bottom)
                }
                make.height.equalTo(Layout.agreementViewHeight)
            }
            previousView = agreementView
        }

        startButton.snp.makeConstraints { make in
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.trailing.equalTo(safeArea).inset(Layout.horizontalMargin)
            make.bottom.equalTo(safeArea).inset(Layout.startButtonBottomSpacing)
            make.height.equalTo(Layout.startButtonHeight)
        }
    }

    override func bind() {
        viewModel.output.agreementStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] agreementStates in
                self?.updateAgreementStates(agreementStates: agreementStates)
            }
            .store(in: &cancellables)


        viewModel.output.agreementResultPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] agreementResult in
                guard let self else { return }
                if agreementResult {
                    BitnagilLogger.log(logType: .debug, message: "약관 동의 성공")
                    guard let onboardingViewModel = DIContainer.shared.resolve(type: OnboardingViewModel.self) else {
                        fatalError("onboardingViewModel 의존성이 등록되지 않았습니다.")
                    }
                    let onboardingView = OnboardingView(viewModel: onboardingViewModel, onboarding: .time)
                    self.navigationController?.pushViewController(onboardingView, animated: true)
                } else {
                    // TODO: 약관 동의 실패 시, 에러 처리를 해야 합니다.
                    BitnagilLogger.log(logType: .error, message: "약관 동의 실패")
                }
            }
            .store(in: &cancellables)
    }

    private func updateAgreementStates(agreementStates: TermsAgreementState) {
        let isAllAgreed = agreementStates.isAllAgreed
        totalAgreementButton.updateButtonState(enableState: isAllAgreed)

        TermsType.allCases.forEach { type in
            let isAgreed = agreementStates.isAgreed(termType: type)
            agreementViews[type]?.updateState(isAgreed: isAgreed)
        }

        startButton.updateButtonState(buttonState: isAllAgreed ? .default : .disabled)
    }
}

// MARK: - TermsAgreementItemViewDelegate
extension TermsAgreementView: TermsAgreementItemViewDelegate {
    func termsAgreementItemView(_ sender: TermsAgreementItemView, didToggleCheckFor termType: TermsType) {
        viewModel.action(input: .toggleAgreement(termsType: termType))
    }

    func termsAgreementItemView(_ sender: TermsAgreementItemView, didTapMoreButtonFor termType: TermsType) {
        guard let url = termType.link else { return }
        let safariView = SFSafariViewController(url: url)
        present(safariView, animated: true)
    }
}
