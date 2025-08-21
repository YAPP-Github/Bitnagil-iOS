//
//  RoutineDeleteViewController.swift
//  Presentation
//
//  Created by 최정인 on 8/20/25.
//

import Shared
import SnapKit
import UIKit

final class RoutineDeleteViewController: BaseViewController<RoutineListViewModel> {
    private enum Layout {
        static let horizontalMargin: CGFloat = 24
        static let mainLabelTopSpacing: CGFloat = 26
        static let mainLabelHeight: CGFloat = 24
        static let subLabelTopSpacing: CGFloat = 10
        static let dailyDeleteButtonTopSpacing: CGFloat = 24
        static let allDeleteButtonTopSpacing: CGFloat = 12
        static let buttonHeight: CGFloat = 54
        static let deleteAlertViewControllerHeight: CGFloat = 204
        static let deleteAlertViewControllerCornerRadius: CGFloat = 20
    }

    private let mainLabel = UILabel()
    private let subLabel = UILabel()
    private let dailyDeleteButton = UIButton()
    private let allDeleteButton = UIButton()
    var onDismiss: (() -> Void)?
    override init(viewModel: RoutineListViewModel) {
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if isBeingDismissed && presentedViewController == nil {
            onDismiss?()
        }
    }

    override func configureAttribute() {
        mainLabel.text = "이 루틴은 반복 설정되어 있어요"
        mainLabel.font = BitnagilFont(style: .title3, weight: .semiBold).font
        mainLabel.textColor = BitnagilColor.gray10

        let subLabelText = "오늘만 삭제하거나, 전체 반복 일정에서 모두 삭제할 수\n있습니다. 삭제한 루틴은 되돌릴 수 없어요."
        subLabel.attributedText = BitnagilFont(style: .body2, weight: .medium).attributedString(text: subLabelText)
        subLabel.numberOfLines = 2
        subLabel.font = BitnagilFont(style: .body2, weight: .medium).font
        subLabel.textColor = BitnagilColor.gray40

        var dailyDeleteButtonConfiguration = UIButton.Configuration.filled()
        dailyDeleteButtonConfiguration.baseBackgroundColor = BitnagilColor.gray10
        dailyDeleteButtonConfiguration.background.cornerRadius = 12
        dailyDeleteButtonConfiguration.attributedTitle = AttributedString(
            "오늘만 삭제",
            attributes: .init([.font: BitnagilFont(style: .body2, weight: .medium).font]))
        dailyDeleteButtonConfiguration.baseForegroundColor = .white
        dailyDeleteButton.configuration = dailyDeleteButtonConfiguration
        dailyDeleteButton.addAction(
            UIAction { [weak self] _ in
                self?.showDeleteAlertViewController(isDeleteAllRoutines: false)
            },
            for: .touchUpInside)

        var allDeleteButtonConfiguration = UIButton.Configuration.filled()
        allDeleteButtonConfiguration.baseBackgroundColor = BitnagilColor.error10
        allDeleteButtonConfiguration.background.cornerRadius = 12
        allDeleteButtonConfiguration.attributedTitle = AttributedString(
            "모든 날짜에서 삭제",
            attributes: .init([.font: BitnagilFont(style: .body2, weight: .medium).font]))
        allDeleteButtonConfiguration.baseForegroundColor = .white
        allDeleteButton.configuration = allDeleteButtonConfiguration
        allDeleteButton.addAction(
            UIAction { [weak self] _ in
                self?.showDeleteAlertViewController(isDeleteAllRoutines: true)
            },
            for: .touchUpInside)
    }

    override func configureLayout() {
        view.backgroundColor = .systemBackground

        view.addSubview(mainLabel)
        view.addSubview(subLabel)
        view.addSubview(dailyDeleteButton)
        view.addSubview(allDeleteButton)

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

        dailyDeleteButton.snp.makeConstraints { make in
            make.top.equalTo(subLabel.snp.bottom).offset(Layout.dailyDeleteButtonTopSpacing)
            make.leading.equalToSuperview().offset(Layout.horizontalMargin)
            make.trailing.equalToSuperview().inset(Layout.horizontalMargin)
            make.height.equalTo(Layout.buttonHeight)
        }

        allDeleteButton.snp.makeConstraints { make in
            make.top.equalTo(dailyDeleteButton.snp.bottom).offset(Layout.allDeleteButtonTopSpacing)
            make.leading.equalToSuperview().offset(Layout.horizontalMargin)
            make.trailing.equalToSuperview().inset(Layout.horizontalMargin)
            make.height.equalTo(Layout.buttonHeight)
        }
    }

    private func showDeleteAlertViewController(isDeleteAllRoutines: Bool) {
        let deleteAlertViewController = RoutineDeleteAlertViewController(viewModel: viewModel, isDeleteAllRoutines: isDeleteAllRoutines)
        deleteAlertViewController.onDismiss = { [weak self] in
            self?.onDismiss?()
        }

        if let sheet = deleteAlertViewController.sheetPresentationController {
            sheet.prefersGrabberVisible = false
            if #available(iOS 16.0, *) {
                sheet.detents = [.custom { _ in Layout.deleteAlertViewControllerHeight }]
            } else {
                sheet.detents = [.medium()]
            }
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.largestUndimmedDetentIdentifier = .none
            sheet.preferredCornerRadius = Layout.deleteAlertViewControllerCornerRadius
        }
        present(deleteAlertViewController, animated: false)
    }
}
