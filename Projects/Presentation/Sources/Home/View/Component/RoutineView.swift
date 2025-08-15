//
//  RoutineView.swift
//  Presentation
//
//  Created by 최정인 on 7/18/25.
//

import Shared
import SnapKit
import UIKit

protocol RoutineViewDelegate: AnyObject {
    func routineView(_ sender: RoutineView, didTapMainRoutineCheckButton mainRoutine: MainRoutine)
    func routineView(_ sender: RoutineView, didTapSubRoutineCheckButton subRoutine: SubRoutine)
}

final class RoutineView: UIView {
    private enum Layout {
        static let timeLabelHeight: CGFloat = 20
    }

    private let timeLabel = UILabel()
    private let containerView = UIView()
    private let mainRoutineView = UIView()
    private let mainRoutineLabel = UILabel()
    private let mainRoutineCheckButton = UIButton()
    private let grayLine = UIView()
    private let subRoutineStackView = UIStackView()

    private var isLayoutConfigured: Bool = false
    private var mainRoutineHeightConstraint: Constraint?
    private var routine: MainRoutine {
        didSet {
            updateRoutineState()
        }
    }
    weak var delegate: RoutineViewDelegate?
    init(routine: MainRoutine) {
        self.routine = routine
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard !isLayoutConfigured else { return }
        isLayoutConfigured = true
    }

    override var intrinsicContentSize: CGSize {
        var baseHeight: CGFloat = 56
        if !routine.subRoutines.isEmpty {
            baseHeight = 100
            baseHeight += (34.0 * CGFloat(routine.subRoutines.count - 1))
        }
        return CGSize(width: UIView.noIntrinsicMetric, height: baseHeight)
    }

    private func configureAttribute() {
        timeLabel.text = routine.startTime.convertToString(dateType: .time24hour)
        timeLabel.font = BitnagilFont(style: .body2, weight: .medium).font
        timeLabel.textColor = BitnagilColor.gray10

        containerView.backgroundColor = .white
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 12

        mainRoutineLabel.text = routine.title
        mainRoutineLabel.font = BitnagilFont(style: .body1, weight: .semiBold).font
        mainRoutineLabel.textColor = BitnagilColor.gray10

        mainRoutineCheckButton.setImage(BitnagilIcon.uncheckedCircleIcon, for: .normal)
        mainRoutineCheckButton.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                var updatedRoutine = routine
                updatedRoutine.isDone.toggle()
                self.routine = updatedRoutine
                delegate?.routineView(self, didTapMainRoutineCheckButton: routine)
            },
            for: .touchUpInside)

        grayLine.backgroundColor = BitnagilColor.gray97
        grayLine.isHidden = routine.subRoutines.isEmpty

        subRoutineStackView.axis = .vertical
        subRoutineStackView.spacing = 10
    }

    private func configureLayout() {
        addSubview(timeLabel)
        addSubview(containerView)

        [mainRoutineLabel, mainRoutineCheckButton].forEach {
            mainRoutineView.addSubview($0)
        }
        containerView.addSubview(mainRoutineView)
        containerView.addSubview(grayLine)
        containerView.addSubview(subRoutineStackView)

        timeLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.height.equalTo(20)
        }

        containerView.snp.makeConstraints { make in
            make.top.trailing.bottom.equalToSuperview()
            make.leading.equalTo(timeLabel.snp.trailing).offset(8)
        }

        mainRoutineView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(8)
            make.height.equalTo(40)
        }

        mainRoutineLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalTo(211)
        }

        mainRoutineCheckButton.snp.makeConstraints { make in
            make.leading.equalTo(mainRoutineLabel.snp.trailing).offset(10)
            mainRoutineHeightConstraint = make.height.equalTo(40).constraint
            make.size.equalTo(40)
        }

        grayLine.snp.makeConstraints { make in
            make.top.equalTo(mainRoutineView.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(1)
        }

        for subRoutine in routine.subRoutines {
            let subRoutineView = makeSubRoutineView(subRoutine: subRoutine)
            subRoutineView.snp.makeConstraints { make in
                make.height.equalTo(24)
            }
            subRoutineStackView.addArrangedSubview(subRoutineView)
        }

        subRoutineStackView.snp.makeConstraints { make in
            make.top.equalTo(grayLine.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
        }
    }

    private func makeSubRoutineView(subRoutine: SubRoutine) -> UIView {
        let subRoutineView = UIView()
        let checkButton = UIButton()
        let subRoutineLabel = UILabel()

        subRoutineView.addSubview(checkButton)
        subRoutineView.addSubview(subRoutineLabel)

        let checkedIcon = BitnagilIcon.checkedCircleSmallIcon
        let uncheckedIcon = BitnagilIcon.uncheckedCircleSmallIcon
        checkButton.setImage(subRoutine.isDone ? checkedIcon : uncheckedIcon, for: .normal)

        checkButton.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.size.equalTo(24)
        }

        subRoutineLabel.text = subRoutine.title
        subRoutineLabel.font = BitnagilFont(style: .body2, weight: .medium).font
        subRoutineLabel.textColor = BitnagilColor.gray40

        subRoutineLabel.snp.makeConstraints { make in
            make.leading.equalTo(checkButton.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
        }

        return subRoutineView
    }

    func updateRoutineState() {
        let isDone = routine.isDone
        mainRoutineCheckButton.setImage(isDone ? BitnagilIcon.checkedCircleIcon : BitnagilIcon.uncheckedCircleIcon, for: .normal)
    }
}
