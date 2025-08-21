//
//  RoutineEditAlertViewController.swift
//  Presentation
//
//  Created by 최정인 on 8/21/25.
//

import Shared
import SnapKit
import UIKit

final class RoutineEditAlertViewController: UIViewController {
    private enum Layout {
        static let horizontalMargin: CGFloat = 24
        static let mainLabelTopSpacing: CGFloat = 26
        static let mainLabelHeight: CGFloat = 24
        static let subLabelTopSpacing: CGFloat = 10
        static let applyTodayButtonTopSpacing: CGFloat = 24
        static let applyTomorrowButtonTopSpacing: CGFloat = 12
        static let buttonHeight: CGFloat = 54
    }

    private let mainLabel = UILabel()
    private let subLabel = UILabel()
    private let applyTodayButton = UIButton()
    private let applyTomorrowButton = UIButton()
    var onDismiss: (() -> Void)?
    var goToRoutineCreationView: ((Bool) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAttribute()
        configureLayout()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isBeingDismissed { onDismiss?() }
    }

    private func configureAttribute() {
        mainLabel.text = "변경한 루틴, 언제 시작할까요?"
        mainLabel.font = BitnagilFont(style: .title3, weight: .semiBold).font
        mainLabel.textColor = BitnagilColor.gray10

        subLabel.text = "변경된 루틴이 반영되는 시점을 선택해 주세요."
        subLabel.font = BitnagilFont(style: .body2, weight: .medium).font
        subLabel.textColor = BitnagilColor.gray40

        var applyTodayButtonConfiguration = UIButton.Configuration.filled()
        applyTodayButtonConfiguration.baseBackgroundColor = BitnagilColor.gray10
        applyTodayButtonConfiguration.background.cornerRadius = 12
        applyTodayButtonConfiguration.attributedTitle = AttributedString(
            "당일부터 적용",
            attributes: .init([.font: BitnagilFont(style: .body2, weight: .medium).font]))
        applyTodayButtonConfiguration.baseForegroundColor = .white
        applyTodayButton.configuration = applyTodayButtonConfiguration
        applyTodayButton.addAction(
            UIAction { [weak self] _ in
                self?.dismiss(animated: true) {
                    self?.goToRoutineCreationView?(true)
                }
            },
            for: .touchUpInside)

        var applyTomorrowButtonConfiguration = UIButton.Configuration.filled()
        applyTomorrowButtonConfiguration.baseBackgroundColor = BitnagilColor.gray10
        applyTomorrowButtonConfiguration.background.cornerRadius = 12
        applyTomorrowButtonConfiguration.attributedTitle = AttributedString(
            "다음 날부터 적용",
            attributes: .init([.font: BitnagilFont(style: .body2, weight: .medium).font]))
        applyTomorrowButtonConfiguration.baseForegroundColor = .white
        applyTomorrowButton.configuration = applyTomorrowButtonConfiguration
        applyTomorrowButton.addAction(
            UIAction { [weak self] _ in
                self?.dismiss(animated: true) {
                    self?.goToRoutineCreationView?(false)
                }
            },
            for: .touchUpInside)
    }

    private func configureLayout() {
        view.backgroundColor = .systemBackground
        view.addSubview(mainLabel)
        view.addSubview(subLabel)
        view.addSubview(applyTodayButton)
        view.addSubview(applyTomorrowButton)

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

        applyTodayButton.snp.makeConstraints { make in
            make.top.equalTo(subLabel.snp.bottom).offset(Layout.applyTodayButtonTopSpacing)
            make.leading.equalToSuperview().offset(Layout.horizontalMargin)
            make.trailing.equalToSuperview().inset(Layout.horizontalMargin)
            make.height.equalTo(Layout.buttonHeight)
        }

        applyTomorrowButton.snp.makeConstraints { make in
            make.top.equalTo(applyTodayButton.snp.bottom).offset(Layout.applyTomorrowButtonTopSpacing)
            make.leading.equalToSuperview().offset(Layout.horizontalMargin)
            make.trailing.equalToSuperview().inset(Layout.horizontalMargin)
            make.height.equalTo(Layout.buttonHeight)
        }
    }
}
