//
//  WithdrawViewController.swift
//  Presentation
//
//  Created by 최정인 on 9/4/25.
//

import Combine
import Shared
import SnapKit
import UIKit

final class WithdrawViewController: BaseViewController<WithdrawViewModel> {
    private enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let mainLabelTopSpacing: CGFloat = 86
        static let mainLabelTopMinSpacing: CGFloat = 60
        static let subLabelTopSpacing: CGFloat = 5
        static let confirmStackViewTopSpacing: CGFloat = 24
        static let confirmStackViewTopMinSpacing: CGFloat = 15
        static let confirmButtonSize: CGFloat = 24
        static let withdrawReasonViewTopSpacing: CGFloat = 62
        static let withdrawReasonViewTopMinSpacing: CGFloat = 22
        static let withdrawChoiceButtonHeight: CGFloat = 56
        static let withdrawReasonTextViewPlaceholderTopSpacing: CGFloat = 13
        static let withdrawReasonTextViewHorizontalMargin: CGFloat = 16
        static let withdrawReasonTextViewVerticalMargin: CGFloat = 13
        static let withdrawReasonTextBackgroundViewHeight: CGFloat = 112
        static let withdrawReasonStackViewTopSpacing: CGFloat = 16
        static let withdrawButtonBottomSpacing: CGFloat = 14
        static let withdrawButtonHeight: CGFloat = 54
    }

    private let mainLabel = UILabel()
    private let subLabel = UILabel()
    private let confirmStackView = UIStackView()
    private let confirmButton = UIButton()
    private let confirmLabel = UILabel()

    private let withdrawReasonView = UIView()
    private let withdrawReasonLabel = UILabel()
    private let withdrawReasonStackView = UIStackView()
    private var withdrawButtons: [WithdrawReason: BitnagilChoiceButton] = [:]
    private let withdrawReasonTextBackgroundView = UIView()
    private let withdrawReasonTextViewPlaceholder = UILabel()
    private let withdrawReasonTextView = UITextView()
    private let withdrawReasonMaxLengthLabel = UILabel()
    private let withdrawReasonMaxLength: Int = 100
    private let withdrawButton = PrimaryButton(buttonState: .disabled, buttonTitle: "탈퇴하기")

    private var isLayoutConfigured: Bool = false
    private var mainLabelTopConstraint: Constraint?
    private var confirmStackViewTopConstraint: Constraint?
    private var withdrawReasonViewTopConstraint: Constraint?
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !isLayoutConfigured {
            updateConstraint()
            isLayoutConfigured = true
        }
    }

    private func updateConstraint() {
        let height = view.bounds.height
        if height <= 667 {
            mainLabelTopConstraint?.update(offset: Layout.mainLabelTopMinSpacing)
            confirmStackViewTopConstraint?.update(offset: Layout.confirmStackViewTopMinSpacing)
            withdrawReasonViewTopConstraint?.update(offset: Layout.withdrawReasonViewTopMinSpacing)
        }
    }

    override func configureAttribute() {
        view.backgroundColor = .systemBackground
        navigationController?.setNavigationBarHidden(true, animated: false)
        configureCustomNavigationBar(navigationBarStyle: .withBackButton(title: "탈퇴하기"))

        mainLabel.text = "정말 탈퇴하시겠어요?"
        mainLabel.font = BitnagilFont(style: .title3, weight: .semiBold).font
        mainLabel.textColor = BitnagilColor.gray10

        let subLabelText = "탈퇴하면 보관 중인 데이터와 서비스 이용 내역이\n모두 삭제되고, 다시 가입해도 복구되지 않아요."
        subLabel.attributedText = BitnagilFont(style: .body1, weight: .medium).attributedString(text: subLabelText)
        subLabel.textColor = BitnagilColor.gray50
        subLabel.numberOfLines = 2

        confirmStackView.axis = .horizontal
        confirmStackView.spacing = 10

        confirmButton.setImage(BitnagilIcon.uncheckedCircleSmallIcon, for: .normal)
        confirmButton.addAction(
            UIAction { [weak self] _ in
                self?.viewModel.action(input: .toggleConfirmButton)
            },
            for: .touchUpInside)

        confirmLabel.text = "유의사항을 확인했어요."
        confirmLabel.font = BitnagilFont(style: .body2, weight: .medium).font
        confirmLabel.textColor = BitnagilColor.gray40

        withdrawReasonView.isHidden = true

        withdrawReasonLabel.text = "탈퇴 사유를 알려주실 수 있나요?"
        withdrawReasonLabel.font = BitnagilFont(style: .title3, weight: .semiBold).font
        withdrawReasonLabel.textColor = BitnagilColor.gray10

        withdrawReasonStackView.axis = .vertical
        withdrawReasonStackView.spacing = 10

        WithdrawReason.allCases.forEach { withdrawReason in
            let withdrawChoiceButton = BitnagilChoiceButton(bitnagilChoice: withdrawReason, forWithdrawChoice: true)
            withdrawChoiceButton.addAction(
                UIAction { [weak self] _ in
                    self?.viewModel.action(input: .choiceWithdrawReason(reason: withdrawReason))
                },
                for: .touchUpInside)

            withdrawChoiceButton.snp.makeConstraints { make in
                make.height.equalTo(Layout.withdrawChoiceButtonHeight)
            }
            withdrawReasonStackView.addArrangedSubview(withdrawChoiceButton)
            withdrawButtons[withdrawReason] = withdrawChoiceButton
        }

        withdrawReasonTextBackgroundView.backgroundColor = BitnagilColor.gray99
        withdrawReasonTextBackgroundView.layer.masksToBounds = true
        withdrawReasonTextBackgroundView.layer.cornerRadius = 12

        withdrawReasonTextViewPlaceholder.attributedText = BitnagilFont(style: .subtitle1, weight: .medium)
            .attributedString(text: "기타사항(직접 입력)")
        withdrawReasonTextViewPlaceholder.textColor = BitnagilColor.gray90

        withdrawReasonTextView.delegate = self
        withdrawReasonTextView.font = BitnagilFont(style: .subtitle1, weight: .medium).font
        withdrawReasonTextView.textColor = BitnagilColor.gray10
        withdrawReasonTextView.backgroundColor = .clear

        withdrawReasonMaxLengthLabel.text = "* 최대 \(withdrawReasonMaxLength)자까지만 입력할 수 있어요."
        withdrawReasonMaxLengthLabel.font = BitnagilFont(style: .body2, weight: .medium).font
        withdrawReasonMaxLengthLabel.textColor = BitnagilColor.error
        withdrawReasonMaxLengthLabel.isHidden = true

        withdrawButton.addAction(
            UIAction { [weak self] _ in
                self?.viewModel.action(input: .withdrawService)
            },
            for: .touchUpInside)
    }

    override func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide

        view.addSubview(mainLabel)
        view.addSubview(subLabel)
        [confirmButton, confirmLabel].forEach {
            confirmStackView.addArrangedSubview($0)
        }
        view.addSubview(confirmStackView)
        [withdrawReasonLabel, withdrawReasonStackView].forEach {
            withdrawReasonView.addSubview($0)
        }
        view.addSubview(withdrawReasonView)
        view.addSubview(withdrawButton)

        mainLabel.snp.makeConstraints { make in
            mainLabelTopConstraint = make.top.equalTo(safeArea).offset(Layout.mainLabelTopSpacing).constraint
            make.horizontalEdges.equalTo(safeArea).inset(Layout.horizontalMargin)
        }

        subLabel.snp.makeConstraints { make in
            make.top.equalTo(mainLabel.snp.bottom).offset(Layout.subLabelTopSpacing)
            make.horizontalEdges.equalTo(safeArea).inset(Layout.horizontalMargin)
        }

        confirmStackView.snp.makeConstraints { make in
            confirmStackViewTopConstraint = make.top.equalTo(subLabel.snp.bottom).offset(Layout.confirmStackViewTopSpacing).constraint
            make.horizontalEdges.equalTo(safeArea).inset(Layout.horizontalMargin)
        }

        confirmButton.snp.makeConstraints { make in
            make.size.equalTo(Layout.confirmButtonSize)
        }

        withdrawReasonView.snp.makeConstraints { make in
            withdrawReasonViewTopConstraint = make.top.equalTo(confirmStackView.snp.bottom).offset(Layout.withdrawReasonViewTopSpacing).constraint
            make.horizontalEdges.equalTo(safeArea)
            make.bottom.equalTo(withdrawButton.snp.top)
        }

        withdrawReasonLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalTo(safeArea).inset(Layout.horizontalMargin)
        }

        withdrawReasonTextBackgroundView.addSubview(withdrawReasonTextViewPlaceholder)
        withdrawReasonTextBackgroundView.addSubview(withdrawReasonTextView)
        withdrawReasonStackView.addArrangedSubview(withdrawReasonTextBackgroundView)
        withdrawReasonStackView.addArrangedSubview(withdrawReasonMaxLengthLabel)

        withdrawReasonTextViewPlaceholder.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Layout.withdrawReasonTextViewPlaceholderTopSpacing)
            make.horizontalEdges.equalToSuperview().inset(Layout.horizontalMargin)
        }

        withdrawReasonTextView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(Layout.withdrawReasonTextViewHorizontalMargin)
            make.verticalEdges.equalToSuperview().inset(Layout.withdrawReasonTextViewVerticalMargin)
        }

        withdrawReasonTextBackgroundView.snp.makeConstraints { make in
            make.height.equalTo(Layout.withdrawReasonTextBackgroundViewHeight)
        }

        withdrawReasonStackView.snp.makeConstraints { make in
            make.top.equalTo(withdrawReasonLabel.snp.bottom).offset(Layout.withdrawReasonStackViewTopSpacing)
            make.horizontalEdges.equalTo(safeArea).inset(Layout.horizontalMargin)
        }

        withdrawButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeArea).inset(Layout.horizontalMargin)
            make.bottom.equalTo(safeArea).inset(Layout.withdrawButtonBottomSpacing)
            make.height.equalTo(Layout.withdrawButtonHeight)
        }
    }

    override func bind() {
        viewModel.output.confirmPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] comfirm in
                self?.updateConfirmButtonState(confirm: comfirm)
            }
            .store(in: &cancellables)

        viewModel.output.withdrawReasonPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] withdrawReason in
                self?.updateWithdrawReason(selectedWithdrawReason: withdrawReason)
            }
            .store(in: &cancellables)

        viewModel.output.withdrawButtonPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] canWithdraw in
                self?.withdrawButton.updateButtonState(buttonState: canWithdraw ? .default : .disabled)
            }
            .store(in: &cancellables)

        viewModel.output.withdrawResultPublisher
            .receive(on: DispatchQueue.main)
            .sink { withdrawResult in
                if withdrawResult {
                    let confirmDialog = BitnagilConfirmDialog(
                        title: "탈퇴가 완료되었어요",
                        message: "이용해 주셔서 감사합니다. 언제든 다시\n돌아오실 수 있어요:)",
                        confirmHandler: {
                            guard
                                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                let sceneDelegate = windowScene.delegate as? UIWindowSceneDelegate,
                                let window = sceneDelegate.window
                            else { return }

                            guard let loginViewModel = DIContainer.shared.resolve(type: LoginViewModel.self)
                            else { fatalError("loginViewModel 의존성이 등록되지 않았습니다.") }

                            let loginView = LoginViewController(viewModel: loginViewModel)
                            let navigationController = UINavigationController(rootViewController: loginView)
                            window?.rootViewController = navigationController
                            window?.makeKeyAndVisible()
                        })

                    confirmDialog.modalPresentationStyle = .overFullScreen
                    self.present(confirmDialog, animated: false)
                }
            }
            .store(in: &cancellables)
    }

    private func updateConfirmButtonState(confirm: Bool) {
        let corfirmButtonImage = confirm ? BitnagilIcon.checkedCircleSmallIcon : BitnagilIcon.uncheckedCircleSmallIcon
        confirmButton.setImage(corfirmButtonImage, for: .normal)
        withdrawReasonView.isHidden = !confirm
    }

    private func updateWithdrawReason(selectedWithdrawReason: WithdrawReason?) {
        withdrawButtons.forEach { withdrawReason in
            let isSelected = withdrawReason.key == selectedWithdrawReason
            withdrawReason.value.updateButtonState(isChecked: isSelected)
        }

        if selectedWithdrawReason != nil {
            withdrawReasonTextView.resignFirstResponder()
            withdrawReasonTextView.text = ""
            withdrawReasonTextViewPlaceholder.isHidden = false
            withdrawReasonMaxLengthLabel.isHidden = true
        }
    }
}

extension WithdrawViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        viewModel.action(input: .choiceWithdrawReason(reason: nil))
    }

    func textViewDidChange(_ textView: UITextView) {
        withdrawReasonTextViewPlaceholder.isHidden = !textView.text.isEmpty

        let reason = textView.text ?? ""
        viewModel.action(input: .inputWithdrawReason(reason: reason))

        let isMaxLength = textView.text.count >= withdrawReasonMaxLength
        withdrawReasonMaxLengthLabel.isHidden = !isMaxLength
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        let newLength = currentText.count + text.count - range.length
        return newLength <= withdrawReasonMaxLength
    }
}
