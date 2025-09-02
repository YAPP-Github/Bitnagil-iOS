//
//  TermsAgreementViewController.swift
//  Presentation
//
//  Created by 최정인 on 7/7/25.
//

import Combine
import Domain
import SafariServices
import Shared
import SnapKit
import UIKit

final class TermsAgreementViewController: BaseViewController<LoginViewModel> {
    private enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let labelTopSpacing: CGFloat = 86
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
    private let startButton = PrimaryButton(buttonState: .disabled, buttonTitle: "다음")
    private var cancellables: Set<AnyCancellable>

    override init(viewModel: LoginViewModel) {
        cancellables = []
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configureAttribute() {
        let text = "빛나길 이용을 위해\n필수 약관에 동의해 주세요."
        agreementLabel.attributedText = BitnagilFont(style: .title2, weight: .bold).attributedString(text: text)
        agreementLabel.textAlignment = .left
        agreementLabel.numberOfLines = 2
        agreementLabel.textColor = BitnagilColor.gray10

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
        navigationController?.setNavigationBarHidden(true, animated: false)
        configureCustomNavigationBar(navigationBarStyle: .withBackButton(title: "약관 동의"))

        view.addSubview(agreementLabel)
        view.addSubview(totalAgreementButton)
        view.addSubview(startButton)

        agreementLabel.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(Layout.labelTopSpacing)
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
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

                    guard let introViewModel = DIContainer.shared.resolve(type: IntroViewModel.self)
                    else { fatalError("introViewModel 의존성이 등록되지 않았습니다.") }

                    let introView = IntroViewController(viewModel: introViewModel)
                    self.navigationController?.pushViewController(introView, animated: true)
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
extension TermsAgreementViewController: TermsAgreementItemViewDelegate {
    func termsAgreementItemView(_ sender: TermsAgreementItemView, didToggleCheckFor termType: TermsType) {
        viewModel.action(input: .toggleAgreement(termsType: termType))
    }

    func termsAgreementItemView(_ sender: TermsAgreementItemView, didTapMoreButtonFor termType: TermsType) {
        guard let url = termType.link else { return }
        let safariView = SFSafariViewController(url: url)
        present(safariView, animated: true)
    }
}
