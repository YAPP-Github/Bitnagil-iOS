//
//  RoutineDeleteAlertViewController.swift
//  Presentation
//
//  Created by 최정인 on 8/20/25.
//

import Combine
import SnapKit
import UIKit

final class RoutineDeleteAlertViewController: BaseViewController<RoutineListViewModel> {
    private enum Layout {
        static let horizontalMargin: CGFloat = 24
        static let mainLabelTopSpacing: CGFloat = 26
        static let mainLabelHeight: CGFloat = 24
        static let subLabelTopSpacing: CGFloat = 10
        static let dismissButtonTopSpacing: CGFloat = 16
        static let dismissButtonTrailingSpacing: CGFloat = 4
        static let dismissButtonWidth: CGFloat = 48
        static let dismissButtonHeight: CGFloat = 44
        static let buttonStackViewTopSpacing: CGFloat = 24
        static let buttonStackViewSpacing: CGFloat = 12
        static let buttonHeight: CGFloat = 54
    }
    
    private let mainLabel = UILabel()
    private let subLabel = UILabel()
    private let dismissButton = UIButton()
    private let buttonStackView = UIStackView()
    private let confirmButton = UIButton()
    private let cancleButton = UIButton()
    private let isDeleteAllRoutines: Bool
    private var cancellables: Set<AnyCancellable>
    var onDismiss: (() -> Void)?
    init(viewModel: RoutineListViewModel, isDeleteAllRoutines: Bool) {
        self.isDeleteAllRoutines = isDeleteAllRoutines
        self.cancellables = []
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isBeingDismissed {
            if let routineDeleteViewController = presentingViewController?.presentingViewController {
                routineDeleteViewController.dismiss(animated: false)
            }
            onDismiss?()
        }
    }

    override func configureAttribute() {
        mainLabel.text = "루틴을 삭제하시겠어요?"
        mainLabel.font = BitnagilFont(style: .title3, weight: .semiBold).font
        mainLabel.textColor = BitnagilColor.gray10

        let subLabelText = "이 루틴과 관련된 모든 기록이 함께 삭제되며, 삭제 후에는\n되돌릴 수 없습니다. 정말 삭제하시겠어요?"
        subLabel.attributedText = BitnagilFont(style: .body2, weight: .medium).attributedString(text: subLabelText)
        subLabel.numberOfLines = 2
        subLabel.font = BitnagilFont(style: .body2, weight: .medium).font
        subLabel.textColor = BitnagilColor.gray40

        dismissButton.setImage(BitnagilIcon.closeIcon, for: .normal)
        dismissButton.addAction(
            UIAction { [weak self] _ in
                self?.dismissToRootView()
            },
            for: .touchUpInside)

        buttonStackView.axis = .horizontal
        buttonStackView.spacing = Layout.buttonStackViewSpacing

        var cancleButtonConfiguration = UIButton.Configuration.filled()
        cancleButtonConfiguration.baseBackgroundColor = BitnagilColor.gray97
        cancleButtonConfiguration.background.cornerRadius = 12
        cancleButtonConfiguration.attributedTitle = AttributedString(
            "취소",
            attributes: .init([.font: BitnagilFont(style: .body2, weight: .medium).font]))
        cancleButtonConfiguration.baseForegroundColor = BitnagilColor.gray40
        cancleButton.configuration = cancleButtonConfiguration
        cancleButton.addAction(
            UIAction { [weak self] _ in
                self?.dismissToRootView()
            }, for: .touchUpInside)


        var confirmButtonConfiguration = UIButton.Configuration.filled()
        confirmButtonConfiguration.baseBackgroundColor = BitnagilColor.gray10
        confirmButtonConfiguration.background.cornerRadius = 12
        confirmButtonConfiguration.attributedTitle = AttributedString(
            "삭제",
            attributes: .init([.font: BitnagilFont(style: .body2, weight: .medium).font]))
        confirmButtonConfiguration.baseForegroundColor = .white
        confirmButton.configuration = confirmButtonConfiguration
        confirmButton.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                self.viewModel.action(input: .deleteRoutine(isDeleteAllRoutines: self.isDeleteAllRoutines))
            },
            for: .touchUpInside)
    }

    override func configureLayout() {
        view.backgroundColor = .systemBackground

        view.addSubview(mainLabel)
        view.addSubview(subLabel)
        view.addSubview(dismissButton)
        view.addSubview(buttonStackView)
        [cancleButton, confirmButton].forEach {
            buttonStackView.addArrangedSubview($0)
        }

        mainLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Layout.mainLabelTopSpacing)
            make.leading.equalToSuperview().offset(Layout.horizontalMargin)
            make.height.equalTo(Layout.mainLabelHeight)
        }

        subLabel.snp.makeConstraints { make in
            make.top.equalTo(mainLabel.snp.bottom).offset(Layout.subLabelTopSpacing)
            make.leading.equalToSuperview().offset(Layout.horizontalMargin)
            make.trailing.equalToSuperview().inset(Layout.horizontalMargin)
        }

        dismissButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Layout.dismissButtonTopSpacing)
            make.trailing.equalToSuperview().inset(Layout.dismissButtonTrailingSpacing)
            make.width.equalTo(Layout.dismissButtonWidth)
            make.height.equalTo(Layout.dismissButtonHeight)
        }

        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(subLabel.snp.bottom).offset(Layout.buttonStackViewTopSpacing)
            make.leading.equalToSuperview().offset(Layout.horizontalMargin)
            make.trailing.equalToSuperview().inset(Layout.horizontalMargin)
            make.height.equalTo(Layout.buttonHeight)
        }
    }

    override func bind() {
        viewModel.output.deleteRoutineResultPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isDeleteRoutine in
                if isDeleteRoutine {
                    self?.dismissToRootView()
                }
            }
            .store(in: &cancellables)
    }

    private func dismissToRootView() {
        if let routineDeleteViewController = presentingViewController?.presentingViewController {
            dismiss(animated: false)
            routineDeleteViewController.dismiss(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}
