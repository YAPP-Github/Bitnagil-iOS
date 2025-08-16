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
        static let checkButtonImageTopSpacing: CGFloat = 24
        static let checkButtonImageSize: CGFloat = 18
        static let checkButtonLabelHeight: CGFloat = 20
        static let checkButtonLabelTrailingSpacing: CGFloat = 6
        static let foldedHeight: CGFloat = 0
    }

    enum Action {
        case repeatDaily
        case repeatWeekly
        case setWeeks([Week])
    }

    struct Dependencies {
        let repeatType: RepeatType?
        let selectedWeeks: [Week]
    }

    private let dailyButton = UIButton()
    private let weeklyButton = UIButton()
    private let weekStackView = UIStackView()
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
        guard heightConstraint?.isActive == expanded else { return }

        subviews.forEach { $0.alpha = 0 }
        defer { self.subviews.forEach { $0.alpha = 1 } }

        self.heightConstraint?.isActive = !expanded
        self.subviews.forEach { $0.isHidden = !expanded }

        if expanded {
            weekStackView.isHidden = !weeklyButton.isSelected
        }
    }

    func configure(dependencies: Dependencies) {
        configureRepeatButton(selectedType: dependencies.repeatType)

        let selectedWeeks = dependencies.selectedWeeks

        weekStackView.subviews.forEach { button in
            guard let button = button as? UIButton else { return }
            button.isSelected = false
            button.backgroundColor = .white
            button.layer.borderColor = BitnagilColor.gray96?.cgColor
        }

        selectedWeeks.forEach {
            let index = $0.id
            guard let button = weekStackView.arrangedSubviews[index] as? UIButton else { return }

            button.isSelected = true
            button.backgroundColor = BitnagilColor.orange500
            button.layer.borderColor = BitnagilColor.orange500?.cgColor
        }
    }
    
    private func configureAttribute() {
        configureWeekStackView()
        weekStackView.isHidden = true

        dailyButton.setTitle("매일", for: .normal)
        weeklyButton.setTitle("요일 선택", for: .normal)
        [dailyButton, weeklyButton].forEach { button in
            button.titleLabel?.font = BitnagilFont.init(style: .body2, weight: .medium).font
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
                self?.configureRepeatButton(selectedType: .daily)
            },
            for: .touchUpInside)

        weeklyButton.addAction(
            UIAction { [weak self] _ in
                self?.configureRepeatButton(selectedType: .weekly)
            },
            for: .touchUpInside)
    }

    private func configureLayout() {
        addSubview(dailyButton)
        addSubview(weeklyButton)
        addSubview(weekStackView)

        self.snp.makeConstraints { make in
            heightConstraint = make.height.equalTo(Layout.foldedHeight).constraint
        }

        dailyButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Layout.edgeSpacing).priority(999)
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
            make.top.equalTo(dailyButton.snp.bottom).offset(Layout.weekStackViewTopSpacing)
            make.horizontalEdges.equalToSuperview().inset(Layout.edgeSpacing)
            make.height.equalTo(Layout.weekStackViewHeight)
            make.bottom.equalToSuperview().offset(-Layout.edgeSpacing).priority(999)
        }
    }

    private func configureWeekStackView() {
        weekStackView.axis = .horizontal
        weekStackView.spacing = 5
        weekStackView.distribution = .fillEqually

        Week.allCases.forEach {
            let button = UIButton()
            let normalLayerColor = BitnagilColor.gray96?.cgColor
            button.layer.cornerRadius = 12
            button.layer.masksToBounds = true
            button.titleLabel?.font = BitnagilFont.init(style: .body2, weight: .medium).font
            button.setTitleColor(BitnagilColor.gray30, for: .normal)
            button.setTitleColor(.white, for: .selected)
            button.setTitle($0.koreanValue, for: .normal)
            button.layer.borderWidth = 1
            button.layer.borderColor = normalLayerColor
            button.backgroundColor = .white

            button.addAction(
                UIAction { action in
                    guard let sender = action.sender as? UIButton else { return }

                    sender.isSelected.toggle()
                    if sender.isSelected {
                        sender.backgroundColor = BitnagilColor.orange500
                        sender.layer.borderColor = BitnagilColor.orange500?.cgColor
                    } else {
                        sender.backgroundColor = .white
                        sender.layer.borderColor = normalLayerColor
                    }
                },
                for: .touchUpInside)
            weekStackView.addArrangedSubview(button)
        }
    }

    private func configureRepeatButton(selectedType: RepeatType?) {
        if let selectedType {
            switch selectedType {
            case .daily:
                dailyButton.isSelected.toggle()
                if dailyButton.isSelected {
                    weeklyButton.isSelected = false
                }
            case .weekly:
                weeklyButton.isSelected.toggle()
                if weeklyButton.isSelected {
                    dailyButton.isSelected = false
                }
            }
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

        if weeklyButton.isSelected {
            let bottomSpacing = Layout.edgeSpacing + Layout.weekStackViewTopSpacing + Layout.weekStackViewHeight
            weekStackView.isHidden = false
            repeatButtonBottomConstraint?.update(offset: -bottomSpacing)
        } else {
            weekStackView.isHidden = true
            repeatButtonBottomConstraint?.update(offset: -Layout.foldedHeight)
        }
    }
}
