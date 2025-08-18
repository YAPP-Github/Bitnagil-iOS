//
//  PeriodContentView.swift
//  Presentation
//
//  Created by 이동현 on 8/14/25.
//

import Domain
import SnapKit
import UIKit

final class RoutinePeriodContentView: UIView, RoutineCreationExpandable {
    enum ButtonType {
        case start
        case end
    }

    private enum Layout {
        static let edgeSpacing: CGFloat = 19
        static let labelTopSpacing: CGFloat = 14
        static let labelHeight: CGFloat = 39
        static let dateButtonHeight: CGFloat = 39
        static let dateButtonWidth: CGFloat = 116
        static let foldedHeight: CGFloat = 0
    }

    enum Action {
        case startDateSetTapped
        case endDateSetTapped
    }

    struct Dependency {
        let dates: (start: Date?, end: Date?)
    }

    private let startLabel = UILabel()
    private let endLabel = UILabel()
    private let startButton = UIButton()
    private let endButton = UIButton()
    var heightConstraint: Constraint?
    var action: ((Action) -> Void)?

    init() {
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()

        // TODO: - 추후 삭제
        configureButon(buttonType: .start, date: Date())
        configureButon(buttonType: .end, date: Date())
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
        if let startDate = dependency.dates.start {
            let startString = startDate.convertToString(dateType: .yearMonthDate)
            startButton.setTitle(startString, for: .normal)
        } else {
            startButton.setTitle("시작 일자 설정", for: .normal)
        }

        if let endDate = dependency.dates.end {
            let endString = endDate.convertToString(dateType: .yearMonthDate)
            endButton.setTitle(endString, for: .normal)
        } else {
            endButton.setTitle("종료 일자 설정", for: .normal)
        }
    }

    private func configureAttribute() {
        startLabel.text = "시작일"
        endLabel.text = "종료일"

        [startLabel, endLabel].forEach {
            $0.font = BitnagilFont.init(style: .body2, weight: .semiBold).font
            $0.textColor = BitnagilColor.gray30
        }

        [startButton, endButton].forEach {
            $0.setTitleColor(BitnagilColor.gray30, for: .normal)
            $0.titleLabel?.font = BitnagilFont.init(style: .body2, weight: .medium).font
            $0.layer.cornerRadius = 12
            $0.layer.masksToBounds = true
            $0.backgroundColor = .white
            $0.layer.borderColor = BitnagilColor.gray97?.cgColor
            $0.layer.borderWidth = 1
        }

        startButton.addAction(
            UIAction { [weak self] _ in
                self?.action?(.startDateSetTapped)
            },
            for: .touchUpInside)

        endButton.addAction(
            UIAction { [weak self] _ in
                self?.action?(.endDateSetTapped)
            },
            for: .touchUpInside)
    }

    private func configureLayout() {
        addSubview(startLabel)
        addSubview(startButton)
        addSubview(endLabel)
        addSubview(endButton)

        self.snp.makeConstraints { make in
            heightConstraint = make.height.equalTo(Layout.foldedHeight).constraint
        }

        startLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Layout.labelTopSpacing).priority(999)
            make.leading.equalTo(Layout.edgeSpacing)
            make.height.equalTo(Layout.labelHeight)
        }

        startButton.snp.makeConstraints { make in
            make.top.equalTo(startLabel)
            make.trailing.equalToSuperview().offset(-Layout.edgeSpacing)
            make.height.equalTo(Layout.dateButtonHeight)
            make.width.equalTo(Layout.dateButtonWidth)
        }

        endLabel.snp.makeConstraints { make in
            make.top.equalTo(startLabel.snp.bottom).offset(Layout.labelTopSpacing)
            make.leading.equalTo(Layout.edgeSpacing)
            make.height.equalTo(Layout.labelHeight)
            make.bottom.equalToSuperview().offset(-Layout.edgeSpacing).priority(999)
        }

        endButton.snp.makeConstraints { make in
            make.top.equalTo(endLabel)
            make.trailing.equalToSuperview().offset(-Layout.edgeSpacing)
            make.height.equalTo(Layout.dateButtonHeight)
            make.width.equalTo(Layout.dateButtonWidth)
        }
    }

    func configureButon(buttonType: ButtonType, date: Date) {
        let button = buttonType == .start ? startButton : endButton

        let dateString = date.convertToString(dateType: .yearMonthDate)
        button.setTitle(dateString, for: .normal)
    }
}
