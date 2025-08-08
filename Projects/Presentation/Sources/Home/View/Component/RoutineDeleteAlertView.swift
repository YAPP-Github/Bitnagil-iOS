//
//  RoutineDeleteAlertView.swift
//  Presentation
//
//  Created by 최정인 on 8/4/25.
//

import SnapKit
import UIKit

protocol RoutineDeleteAlertViewDelegate: AnyObject {
    func routineDeleteAlertViewDidTapDeleteAllRoutine(_ sender: RoutineDeleteAlertView)
    func routineDeleteAlertViewDidTapDeleteDailyRoutine(_ sender: RoutineDeleteAlertView)
}

final class RoutineDeleteAlertView: UIView {

    private enum Layout {
        static let deleteLabelHeight: CGFloat = 48
        static let deleteLabelTopSpacing: CGFloat = 23
        static let buttonHorizontalMargin: CGFloat = 23
        static let buttonHeight: CGFloat = 44
        static let deleteDailyRoutineButtonTopSpacing: CGFloat = 22
        static let deleteAllRoutineButtonTopSpacing: CGFloat = 10
    }

    private let contentView = UIView()
    private let deleteLabel = UILabel()
    private let deleteDailyRoutineButton = UIButton()
    private let deleteAllRoutineButton = UIButton()
    weak var delegate: RoutineDeleteAlertViewDelegate?

    init() {
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureAttribute() {
        contentView.backgroundColor = .white
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 20

        deleteLabel.text = "해당 루틴은\n반복 루틴으로 설정되어 있어요"
        deleteLabel.numberOfLines = 2
        deleteLabel.textAlignment = .center
        deleteLabel.font = BitnagilFont(style: .body1, weight: .semiBold).font
        deleteLabel.textColor = BitnagilColor.gray10

        var deleteDailyRoutineButtonConfiguration = UIButton.Configuration.filled()
        deleteDailyRoutineButtonConfiguration.baseBackgroundColor = .white
        deleteDailyRoutineButtonConfiguration.background.cornerRadius = 8
        deleteDailyRoutineButtonConfiguration.attributedTitle = AttributedString(
            "당일만 삭제",
            attributes: .init([.font: BitnagilFont(style: .body2, weight: .medium).font]))
        deleteDailyRoutineButtonConfiguration.baseForegroundColor = BitnagilColor.navy500
        deleteDailyRoutineButtonConfiguration.background.strokeColor = BitnagilColor.navy500
        deleteDailyRoutineButtonConfiguration.background.strokeWidth = 1
        deleteDailyRoutineButton.configuration = deleteDailyRoutineButtonConfiguration
        deleteDailyRoutineButton.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                self.delegate?.routineDeleteAlertViewDidTapDeleteDailyRoutine(self)
            },
            for: .touchUpInside)

        var deleteAllRoutineButtonConfiguration = UIButton.Configuration.filled()
        deleteAllRoutineButtonConfiguration.baseBackgroundColor = .white
        deleteAllRoutineButtonConfiguration.background.cornerRadius = 8
        deleteAllRoutineButtonConfiguration.attributedTitle = AttributedString(
            "전체 루틴 삭제",
            attributes: .init([.font: BitnagilFont(style: .body2, weight: .medium).font]))
        deleteAllRoutineButtonConfiguration.baseForegroundColor = BitnagilColor.navy500
        deleteAllRoutineButtonConfiguration.background.strokeColor = BitnagilColor.navy500
        deleteAllRoutineButtonConfiguration.background.strokeWidth = 1
        deleteAllRoutineButton.configuration = deleteAllRoutineButtonConfiguration
        deleteAllRoutineButton.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                self.delegate?.routineDeleteAlertViewDidTapDeleteAllRoutine(self)
            },
            for: .touchUpInside)
    }

    private func configureLayout() {
        addSubview(contentView)

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        [deleteLabel, deleteDailyRoutineButton, deleteAllRoutineButton].forEach {
            contentView.addSubview($0)
        }

        deleteLabel.snp.makeConstraints { make in
            make.height.equalTo(Layout.deleteLabelHeight)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Layout.deleteLabelTopSpacing)
        }

        deleteDailyRoutineButton.snp.makeConstraints { make in
            make.top.equalTo(deleteLabel.snp.bottom).offset(Layout.deleteDailyRoutineButtonTopSpacing)
            make.leading.equalToSuperview().offset(Layout.buttonHorizontalMargin)
            make.trailing.equalToSuperview().inset(Layout.buttonHorizontalMargin)
            make.height.equalTo(Layout.buttonHeight)
        }

        deleteAllRoutineButton.snp.makeConstraints { make in
            make.top.equalTo(deleteDailyRoutineButton.snp.bottom).offset(Layout.deleteAllRoutineButtonTopSpacing)
            make.leading.equalToSuperview().offset(Layout.buttonHorizontalMargin)
            make.trailing.equalToSuperview().inset(Layout.buttonHorizontalMargin)
            make.height.equalTo(Layout.buttonHeight)
        }
    }
}
