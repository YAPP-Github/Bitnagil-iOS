//
//  TimeContentView.swift
//  Presentation
//
//  Created by 이동현 on 8/15/25.
//

import Domain
import SnapKit
import UIKit

final class RoutineTimeContentView: UIView, RoutineCreationExpandable {
    private enum Layout {
        static let edgeSpacing: CGFloat = 19
        static let timeLabelTopSpacing: CGFloat = 14
        static let timeLabelHeight: CGFloat = 39
        static let timeButtonTopSpacing: CGFloat = 14
        static let timeButtonHeight: CGFloat = 39
        static let timeButtonWidth: CGFloat = 116
        static let checkButtonImageViewTopSpacing: CGFloat = 21
        static let checkButtonImageViewSize: CGFloat = 18
        static let checkButtonLabelHeight: CGFloat = 20
        static let checkButtonLabelTrailingSpacing: CGFloat = 6
        static let foldedHeight: CGFloat = 0
    }

    enum Action {
        case allDayTapped
        case timeSetTapped
    }

    struct Dependency {
        let startTime: Date?
    }

    private let timeLabel = UILabel()
    private let timeButton = UIButton()
    private let checkButtonImageView = UIImageView()
    private let checkLabel = UILabel()
    private let checkButton = UIButton()

    var heightConstraint: Constraint?
    var action: ((Action) -> Void)?

    init() {
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setExpanded(expanded: Bool) {
        guard heightConstraint?.isActive == expanded else { return }

        subviews.forEach { $0.alpha = 0 }
        defer { self.subviews.forEach { $0.alpha = 1 } }

        self.heightConstraint?.isActive = !expanded
        self.subviews.forEach { $0.isHidden = !expanded }
    }

    func configure(dependency: Dependency) {
        guard let time = dependency.startTime else {
            timeButton.setTitle("시간선택", for: .normal)
            checkButtonImageView.image = BitnagilIcon.uncheckedIcon
            return
        }

        if time.isMidnight {
            timeButton.setTitle("하루종일", for: .normal)
            checkButtonImageView.image = BitnagilIcon.checkedIcon
        } else {
            timeButton.setTitle(time.convertToString(dateType: .amPmTimeShort), for: .normal)
            checkButtonImageView.image = UIImage()
        }
    }

    private func configureAttribute() {
        timeLabel.text = "시작 시간"
        timeLabel.font = BitnagilFont.init(style: .body2, weight: .semiBold).font

        timeButton.layer.cornerRadius = 12
        timeButton.layer.borderWidth = 1
        timeButton.layer.borderColor = BitnagilColor.gray97?.cgColor
        timeButton.backgroundColor = .white
        timeButton.setTitleColor(BitnagilColor.gray30, for: .normal)
        timeButton.titleLabel?.font = BitnagilFont.init(style: .body2, weight: .medium).font

        checkLabel.text = "하루종일"
        checkLabel.font = BitnagilFont.init(style: .body2, weight: .medium).font

        checkButtonImageView.layer.cornerRadius = 4
        checkButtonImageView.layer.borderWidth = 1
        checkButtonImageView.layer.masksToBounds = true
        checkButtonImageView.backgroundColor = .white
        checkButtonImageView.layer.borderColor = BitnagilColor.gray95?.cgColor

        timeButton.addAction(
            UIAction { [weak self] _ in
                self?.action?(.timeSetTapped)
            },
            for: .touchUpInside)

        checkButton.addAction(
            UIAction { [weak self] _ in
                self?.action?(.allDayTapped)
            },
            for: .touchUpInside)
    }

    private func configureLayout() {
        addSubview(timeLabel)
        addSubview(timeButton)
        addSubview(checkLabel)
        addSubview(checkButtonImageView)
        addSubview(checkButton)

        self.snp.makeConstraints { make in
            heightConstraint = make.height.equalTo(Layout.foldedHeight).constraint
        }

        timeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Layout.timeLabelTopSpacing).priority(999)
            make.height.equalTo(Layout.timeLabelHeight)
            make.leading.equalTo(Layout.edgeSpacing)
        }

        timeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Layout.timeButtonTopSpacing).priority(999)
            make.trailing.equalToSuperview().offset(-Layout.edgeSpacing)
            make.height.equalTo(Layout.timeButtonHeight)
            make.width.equalTo(Layout.timeButtonWidth)
        }

        checkButtonImageView.snp.makeConstraints { make in
            make.top.equalTo(timeButton.snp.bottom).offset(Layout.checkButtonImageViewTopSpacing)
            make.size.equalTo(Layout.checkButtonImageViewSize)
            make.trailing.equalToSuperview().offset(-Layout.edgeSpacing)
            make.bottom.equalToSuperview().offset(-Layout.edgeSpacing).priority(999)
        }

        checkLabel.snp.makeConstraints { make in
            make.centerY.equalTo(checkButtonImageView)
            make.trailing.equalTo(checkButtonImageView.snp.leading).offset(-Layout.checkButtonLabelTrailingSpacing)
        }

        checkButton.snp.makeConstraints { make in
            make.leading.equalTo(checkLabel)
            make.verticalEdges.equalTo(checkButtonImageView)
            make.trailing.equalTo(checkButtonImageView)
        }
    }

    func configureTime(time: Date) {
        let timeString = time.convertToString(dateType: .amPmTimeShort)
        timeButton.setTitle(timeString, for: .normal)
    }
}
