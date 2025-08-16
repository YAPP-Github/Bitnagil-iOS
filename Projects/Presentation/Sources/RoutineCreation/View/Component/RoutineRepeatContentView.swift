//
//  RoutineRepeatContentView.swift
//  Presentation
//
//  Created by 이동현 on 8/12/25.
//

import Domain
import SnapKit
import UIKit

final class RoutineRepeatContentView: UIView, RoutineCreationExpandable {
    private enum Layout {
        static let edgeSpacing: CGFloat = 19
        static let repeatButtonTopSpacing: CGFloat = 14
        static let repeatButtonHeight: CGFloat = 39
        static let repeaetButtonBetweenSpacing: CGFloat = 13
        static let weekStackViewTopSpacing: CGFloat = 15
        static let weekStackViewHeight: CGFloat = 38
        static let weekStackViewSpacing: CGFloat = 5
        static let foldedHeight: CGFloat = 0
    }

    enum Action {
        case repeatDaily
        case repeatWeekly
        case setWeeks([Week])
    }

    struct Dependency {
        let repeatType: RepeatType?
    }

    private let dailyButton = UIButton()
    private let weeklyButton = UIButton()
    private let weekStackView = UIStackView()
    private var buttonToWeek: [UIButton: Week] = [:]
    private var repeatButtonBottomConstraint: Constraint?
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
        let isCollapsed = (heightConstraint?.isActive ?? false)
        if expanded == !isCollapsed { return }

        heightConstraint?.isActive = !expanded

        subviews.forEach { $0.isHidden = !expanded }

        updateWeekVisibility()
    }

    func configure(dependency: Dependency) {
        applyRepeatType(repeatType: dependency.repeatType)
        updateWeekButtons(repeatType: dependency.repeatType)
        updateWeekVisibility()
    }

    private func configureAttribute() {
        configureWeekStackView()
        weekStackView.isHidden = true

        dailyButton.setTitle("매일", for: .normal)
        weeklyButton.setTitle("요일 선택", for: .normal)

        [dailyButton, weeklyButton].forEach { button in
            button.titleLabel?.font = BitnagilFont(style: .body2, weight: .medium).font
            button.setTitleColor(BitnagilColor.gray30, for: .normal)
            button.setTitleColor(.white, for: .selected)
            button.layer.cornerRadius = 12
            button.layer.masksToBounds = true
            button.layer.borderWidth = 1
            button.layer.borderColor = BitnagilColor.gray97?.cgColor
            button.backgroundColor = .white
        }

        dailyButton.addAction(
            UIAction { [weak self] _ in
                self?.action?(.repeatDaily)
            },
            for: .touchUpInside
        )

        weeklyButton.addAction(
            UIAction { [weak self] _ in
                self?.action?(.repeatWeekly)
            },
            for: .touchUpInside
        )
    }

    private func configureLayout() {
        addSubview(dailyButton)
        addSubview(weeklyButton)
        addSubview(weekStackView)

        snp.makeConstraints { make in
            heightConstraint = make.height.equalTo(Layout.foldedHeight).constraint
        }

        dailyButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Layout.repeatButtonTopSpacing).priority(999)
            make.leading.equalToSuperview().offset(Layout.edgeSpacing)
            make.height.equalTo(Layout.repeatButtonHeight)
            repeatButtonBottomConstraint = make.bottom.equalToSuperview()
                .offset(-Layout.edgeSpacing)
                .priority(999)
                .constraint
        }

        weeklyButton.snp.makeConstraints { make in
            make.top.equalTo(dailyButton)
            make.leading.equalTo(dailyButton.snp.trailing).offset(Layout.repeaetButtonBetweenSpacing)
            make.trailing.equalToSuperview().offset(-Layout.edgeSpacing)
            make.height.equalTo(Layout.repeatButtonHeight)
            make.width.equalTo(dailyButton)
            make.bottom.equalTo(dailyButton)
        }

        weekStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(Layout.edgeSpacing)
            make.height.equalTo(Layout.weekStackViewHeight)
            make.bottom.equalToSuperview().offset(-Layout.edgeSpacing).priority(999)
        }
    }

    private func configureWeekButton(weekButton: UIButton) {
        if weekButton.isSelected {
            weekButton.backgroundColor = BitnagilColor.orange500
            weekButton.layer.borderColor = BitnagilColor.orange500?.cgColor
        } else {
            weekButton.backgroundColor = .white
            weekButton.layer.borderColor = BitnagilColor.gray96?.cgColor
        }
    }

    private func configureWeekStackView() {
        weekStackView.axis = .horizontal
        weekStackView.spacing = Layout.weekStackViewSpacing
        weekStackView.distribution = .fillEqually

        Week.allCases.forEach { week in
            let button = UIButton()

            button.layer.cornerRadius = 12
            button.layer.masksToBounds = true
            button.titleLabel?.font = BitnagilFont(style: .body2, weight: .medium).font
            button.setTitleColor(BitnagilColor.gray30, for: .normal)
            button.setTitleColor(.white, for: .selected)
            button.setTitle(week.koreanValue, for: .normal)
            button.layer.borderWidth = 1
            button.layer.borderColor = BitnagilColor.gray96?.cgColor
            button.backgroundColor = .white

            buttonToWeek[button] = week

            button.addAction(
                UIAction { [weak self] action in
                    guard
                        let self,
                        let sender = action.sender as? UIButton
                    else { return }

                    sender.isSelected.toggle()
                    configureWeekButton(weekButton: sender)
                    self.emitSelectedWeeks()
                },
                for: .touchUpInside
            )

            weekStackView.addArrangedSubview(button)
        }
    }

    private func applyRepeatType(repeatType: RepeatType?) {
        switch repeatType {
        case .daily:
            dailyButton.isSelected = true
            weeklyButton.isSelected = false
        case .weekly:
            dailyButton.isSelected = false
            weeklyButton.isSelected = true
        case .none:
            dailyButton.isSelected = false
            weeklyButton.isSelected = false
        }

        [dailyButton, weeklyButton].forEach {
            if $0.isSelected {
                $0.backgroundColor = BitnagilColor.gray10
                $0.layer.borderColor = BitnagilColor.gray10?.cgColor
            } else {
                $0.backgroundColor = .white
                $0.layer.borderColor = BitnagilColor.gray97?.cgColor
            }
        }
    }

    private func updateWeekButtons(repeatType: RepeatType?) {
        switch repeatType {
        case .weekly(let weeks):
            weekStackView.arrangedSubviews
                .compactMap { $0 as? UIButton }
                .forEach { button in
                    let isSelected = buttonToWeek[button].map { weeks.contains($0) } ?? false
                    button.isSelected = isSelected
                    configureWeekButton(weekButton: button)
                }
        default:
            weekStackView.arrangedSubviews
                .compactMap { $0 as? UIButton }
                .forEach { button in
                    button.isSelected = false
                    configureWeekButton(weekButton: button)
                }
        }
    }

    private func updateWeekVisibility() {
        let isCollapsed = (heightConstraint?.isActive ?? false)
        guard !isCollapsed else {
            weekStackView.isHidden = true
            return
        }

        if weeklyButton.isSelected {
            weekStackView.isHidden = false
            let bottomSpacing = Layout.edgeSpacing + Layout.weekStackViewTopSpacing + Layout.weekStackViewHeight
            repeatButtonBottomConstraint?.update(offset: -bottomSpacing)
        } else {
            weekStackView.isHidden = true
            repeatButtonBottomConstraint?.update(offset: -Layout.edgeSpacing)
        }
    }

    private func emitSelectedWeeks() {
        guard weeklyButton.isSelected else { return }

        let weeks: [Week] = weekStackView
            .arrangedSubviews
            .compactMap { subview in
                guard
                    let button = subview as? UIButton,
                    button.isSelected,
                    let week = buttonToWeek[button]
                else { return nil }

                return week
            }
        .sorted { $0.id < $1.id }

        action?(.setWeeks(weeks))
    }
}
