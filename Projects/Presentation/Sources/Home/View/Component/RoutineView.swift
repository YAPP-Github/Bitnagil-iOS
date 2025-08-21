//
//  RoutineView.swift
//  Presentation
//
//  Created by 최정인 on 7/18/25.
//

import Shared
import SnapKit
import UIKit

final class RoutineView: UIView {
    private enum Layout {
        static let horizontalMargin: CGFloat = 16
        static let routineContentStackViewSpacing: CGFloat = 10
        static let routineContentStackViewVerticalMargin: CGFloat = 10
        static let timeLabelWidth: CGFloat = 42
        static let containerViewLeadingSpacing: CGFloat = 8
        static let mainRoutineViewHeight: CGFloat = 28
        static let mainRoutineLabelTrailingSpacing: CGFloat = 10
        static let mainRoutineCheckButtonSize: CGFloat = 28
        static let grayLineHeight: CGFloat = 1
        static let subRoutineViewHeight: CGFloat = 24
        static let subRoutineLabelLeadingSpacing: CGFloat = 10
        static let subRoutineCheckButtonSize: CGFloat = 24
    }

    private let timeLabel = UILabel()
    private let containerView = UIView()
    private let routineContentStackView = UIStackView()
    private let mainRoutineView = UIView()
    private let mainRoutineLabel = UILabel()
    private let mainRoutineCheckButton = UIButton()
    private let grayLine = UIView()
    private var routine: Routine {
        didSet {
            updateRoutineState()
        }
    }

    init(routine: Routine) {
        self.routine = routine
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        var timeLabelText = routine.startTime.convertToString(dateType: .time24hour)
        if timeLabelText == "00:00" {
            timeLabelText = "하루 종일"
        }
        timeLabel.text = timeLabelText
        timeLabel.font = BitnagilFont(style: .body2, weight: .medium).font
        timeLabel.textColor = BitnagilColor.gray10
        timeLabel.numberOfLines = 2

        containerView.backgroundColor = .white
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 12

        routineContentStackView.axis = .vertical
        routineContentStackView.spacing = Layout.routineContentStackViewSpacing

        mainRoutineLabel.text = routine.title
        mainRoutineLabel.font = BitnagilFont(style: .body1, weight: .semiBold).font
        mainRoutineLabel.textColor = BitnagilColor.gray10
        mainRoutineLabel.numberOfLines = 0

        let mainRoutineCheckIcon = routine.isDone ? BitnagilIcon.checkedCircleIcon : BitnagilIcon.uncheckedCircleIcon
        mainRoutineCheckButton.setImage(mainRoutineCheckIcon, for: .normal)
        mainRoutineCheckButton.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                var updatedRoutine = routine
                updatedRoutine.isDone.toggle()
                self.routine = updatedRoutine
            },
            for: .touchUpInside)

        grayLine.backgroundColor = BitnagilColor.gray97
        grayLine.isHidden = routine.subRoutines.isEmpty
    }

    private func configureLayout() {
        addSubview(timeLabel)
        addSubview(containerView)

        [mainRoutineLabel, mainRoutineCheckButton].forEach {
            mainRoutineView.addSubview($0)
        }

        [mainRoutineView, grayLine].forEach {
            routineContentStackView.addArrangedSubview($0)
        }

        for subRoutine in zip(routine.subRoutines, routine.subRoutineCompleted) {
            let subRoutineView = makeSubRoutineView(subRoutine: subRoutine)
            routineContentStackView.addArrangedSubview(subRoutineView)
        }

        containerView.addSubview(routineContentStackView)

        timeLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.width.equalTo(Layout.timeLabelWidth)
        }

        containerView.snp.makeConstraints { make in
            make.top.trailing.bottom.equalToSuperview()
            make.leading.equalTo(timeLabel.snp.trailing).offset(Layout.containerViewLeadingSpacing)
        }

        routineContentStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Layout.horizontalMargin)
            make.trailing.equalToSuperview().inset(Layout.horizontalMargin)
            make.top.equalToSuperview().offset(Layout.routineContentStackViewVerticalMargin)
            make.bottom.equalToSuperview().inset(Layout.routineContentStackViewVerticalMargin)
        }

        mainRoutineView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(Layout.mainRoutineViewHeight)
        }

        mainRoutineLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalTo(mainRoutineCheckButton.snp.leading).offset(-Layout.mainRoutineLabelTrailingSpacing)
        }

        mainRoutineCheckButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
            make.size.equalTo(Layout.mainRoutineCheckButtonSize)
        }

        grayLine.snp.makeConstraints { make in
            make.height.equalTo(Layout.grayLineHeight)
        }
    }

    private func makeSubRoutineView(subRoutine: (title: String, isDone: Bool)) -> UIView {
        let subRoutineView = UIView()
        let checkButton = UIButton()
        let subRoutineLabel = UILabel()

        subRoutineView.addSubview(checkButton)
        subRoutineView.addSubview(subRoutineLabel)

        let subRoutineCheckIcon = subRoutine.isDone ? BitnagilIcon.checkedCircleSmallIcon : BitnagilIcon.uncheckedCircleSmallIcon
        checkButton.setImage(subRoutineCheckIcon, for: .normal)

        subRoutineLabel.text = subRoutine.title
        subRoutineLabel.font = BitnagilFont(style: .body2, weight: .medium).font
        subRoutineLabel.textColor = BitnagilColor.gray40
        subRoutineLabel.numberOfLines = 0

        checkButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalTo(subRoutineLabel)
            make.size.equalTo(Layout.subRoutineCheckButtonSize)
        }

        subRoutineLabel.snp.makeConstraints { make in
            make.leading.equalTo(checkButton.snp.trailing).offset(Layout.subRoutineLabelLeadingSpacing)
            make.trailing.equalToSuperview()
            make.verticalEdges.equalToSuperview()
        }

        subRoutineView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(Layout.subRoutineViewHeight)
        }

        return subRoutineView
    }

    func updateRoutineState() {
        let isDone = routine.isDone
        mainRoutineCheckButton.setImage(isDone ? BitnagilIcon.checkedCircleIcon : BitnagilIcon.uncheckedCircleIcon, for: .normal)
    }
}
