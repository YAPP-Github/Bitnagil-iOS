//
//  RoutineView.swift
//  Presentation
//
//  Created by 최정인 on 7/18/25.
//

import SnapKit
import UIKit

protocol RoutineViewDelegate: AnyObject {
    func routineView(_ sender: RoutineView, didTapMainRoutineCheckButton mainRoutine: MainRoutine)
    func routineView(_ sender: RoutineView, didTapMainRoutineMoreButton mainRoutine: MainRoutine)
    func routineView(_ sender: RoutineView, didTapSubRoutineCheckButton subRoutine: SubRoutine)
}

final class RoutineView: UIView {

    private enum Layout {
        static let dotSize: CGFloat = 8
        static let subRoutineStackViewSpacing: CGFloat = 0
        static let timeLabelHeight: CGFloat = 18
        static let lineLeadingSpacing: CGFloat = 9
        static let lineWidth: CGFloat = 1
        static let mainRoutineViewTopSpacing: CGFloat = 10
        static let mainRoutineViewLeadingSpacing: CGFloat = 6
        static let mainRoutineViewHeight: CGFloat = 61
        static let subRoutineLabelTopSpacing: CGFloat = 10
        static let subRoutineLabelLeadingSpacing: CGFloat = 16
        static let subRoutineLabelHeight: CGFloat = 18
        static let subRoutineStackViewTopSpacing: CGFloat = 8
        static let subRoutineViewHeight: CGFloat = 34
    }

    private let timeLabel = UILabel()
    private let line = UIView()
    private let dot = UIView()
    private lazy var mainRoutineView = MainRoutineView(mainRoutine: routine)
    private let subRoutineLabel = UILabel()
    private let subRoutineStackView = UIStackView()
    private var subRoutineButtons: [String: SubRoutineButton] = [:]

    private var routine: MainRoutine
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

    override var intrinsicContentSize: CGSize {
        let baseHeight = Layout.timeLabelHeight + Layout.mainRoutineViewTopSpacing + Layout.mainRoutineViewHeight

        if routine.subRoutines.isEmpty {
            return CGSize(width: UIView.noIntrinsicMetric, height: baseHeight)
        } else {
            let subRoutineHeight = Layout.subRoutineLabelTopSpacing + Layout.subRoutineLabelHeight + Layout.subRoutineStackViewTopSpacing + (CGFloat(routine.subRoutines.count) * Layout.subRoutineViewHeight)
            return CGSize(width: UIView.noIntrinsicMetric, height: baseHeight + subRoutineHeight)
        }
    }

    private func configureAttribute() {
        timeLabel.text = "\(routine.startTime.convertToString(dateType: .amPmTimeShort))부터 시작"
        timeLabel.font = BitnagilFont(style: .caption1, weight: .regular).font
        timeLabel.textColor = BitnagilColor.navy300

        line.backgroundColor = BitnagilColor.lightBlue300

        dot.backgroundColor = BitnagilColor.navy500
        dot.layer.cornerRadius = Layout.dotSize / 2

        mainRoutineView.delegate = self

        subRoutineLabel.text = "세부 루틴"
        subRoutineLabel.font = BitnagilFont(style: .caption1, weight: .medium).font
        subRoutineLabel.textColor = BitnagilColor.gray60

        subRoutineStackView.axis = .vertical
        subRoutineStackView.spacing = Layout.subRoutineStackViewSpacing
    }

    private func configureLayout() {
        addSubview(timeLabel)
        addSubview(line)
        addSubview(dot)
        addSubview(mainRoutineView)
        addSubview(subRoutineLabel)
        addSubview(subRoutineStackView)

        timeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.height.equalTo(Layout.timeLabelHeight)
        }

        line.snp.makeConstraints { make in
            make.top.equalTo(mainRoutineView)
            if routine.subRoutines.isEmpty {
                make.bottom.equalTo(mainRoutineView)
            } else {
                make.bottom.equalTo(subRoutineStackView)
            }
            make.leading.equalToSuperview().offset(Layout.lineLeadingSpacing)
            make.width.equalTo(Layout.lineWidth)
        }

        dot.snp.makeConstraints { make in
            make.size.equalTo(Layout.dotSize)
            make.centerX.equalTo(line)
            make.centerY.equalTo(mainRoutineView)
        }

        mainRoutineView.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(Layout.mainRoutineViewTopSpacing)
            make.leading.equalTo(dot.snp.trailing).offset(Layout.mainRoutineViewLeadingSpacing)
            make.trailing.equalToSuperview()
            make.height.equalTo(Layout.mainRoutineViewHeight)
        }

        subRoutineLabel.snp.makeConstraints { make in
            make.top.equalTo(mainRoutineView.snp.bottom).offset(Layout.subRoutineLabelTopSpacing)
            make.leading.equalTo(mainRoutineView.snp.leading).offset(Layout.subRoutineLabelLeadingSpacing)
            make.height.equalTo(Layout.subRoutineLabelHeight)
        }

        subRoutineStackView.snp.makeConstraints { make in
            make.top.equalTo(subRoutineLabel.snp.bottom).offset(Layout.subRoutineStackViewTopSpacing)
            make.horizontalEdges.equalTo(mainRoutineView)
        }

        for subRoutine in routine.subRoutines {
            let subRoutineView = SubRoutineButton(subRoutine: subRoutine)
            subRoutineButtons[subRoutine.id] = subRoutineView
            subRoutineView.addAction(UIAction { [weak self] _ in
                guard let self else { return }
                self.delegate?.routineView(self, didTapSubRoutineCheckButton: subRoutine)
            }, for: .touchUpInside)
            subRoutineStackView.addArrangedSubview(subRoutineView)
            subRoutineView.snp.makeConstraints { make in
                make.horizontalEdges.equalToSuperview()
                make.height.equalTo(Layout.subRoutineViewHeight)
            }
        }

        if routine.subRoutines.isEmpty {
            subRoutineLabel.isHidden = true
            subRoutineStackView.isHidden = true
        }
    }

    func updateMainRoutineState(isDone: Bool) {
        mainRoutineView.updateState(isDone: isDone)
        for subRoutine in routine.subRoutines {
            updateSubRoutineState(subRoutine: subRoutine, isDone: isDone)
        }
    }

    func updateSubRoutineState(subRoutine: SubRoutine, isDone: Bool) {
        guard let index = routine.subRoutines.firstIndex(where: { $0.id == subRoutine.id })
        else { return }
        routine.subRoutines[index].isDone.toggle()

        let isDone = routine.subRoutines[index].isDone
        if let subRoutineView = subRoutineButtons[subRoutine.id] {
            subRoutineView.updateState(isDone: isDone)
        }
        checkSubRoutines()
    }

    func checkSubRoutines() {
        let isDoneAllSubRoutines = routine.subRoutines.filter({ $0.isDone }).count == routine.subRoutines.count
        mainRoutineView.updateState(isDone: isDoneAllSubRoutines)
    }
}

// MARK: MainRoutineViewDelegate
extension RoutineView: MainRoutineViewDelegate {
    func mainRoutineView(_ sender: MainRoutineView, didTapCheckButton mainRoutine: MainRoutine) {
        delegate?.routineView(self, didTapMainRoutineCheckButton: mainRoutine)
    }
    
    func mainRoutineView(_ sender: MainRoutineView, didTapMoreButton mainRoutine: MainRoutine) {
        delegate?.routineView(self, didTapMainRoutineMoreButton: mainRoutine)
    }
}
