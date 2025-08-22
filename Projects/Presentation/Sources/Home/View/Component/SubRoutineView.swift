//
//  SubRoutineView.swift
//  Presentation
//
//  Created by 최정인 on 8/22/25.
//

import SnapKit
import UIKit

protocol SubRoutineViewDelegate: AnyObject {
    func subRoutineView(_ sender: SubRoutineView, didTapSubRoutine index: Int)
}

final class SubRoutineView: UIView {
    private enum Layout {
        static let subRoutineViewHeight: CGFloat = 24
        static let subRoutineLabelLeadingSpacing: CGFloat = 10
        static let subRoutineCheckButtonSize: CGFloat = 24
    }
    private let subRoutineView = UIView()
    private let subRoutineCheckButton = UIButton()
    private let subRoutineLabel = UILabel()
    private let index: Int
    private var subRoutine: (title: String, isDone: Bool) {
        didSet {
            updateSubRoutineState()
        }
    }
    weak var delegate: SubRoutineViewDelegate?
    init(subRoutine: (title: String, isDone: Bool), index: Int) {
        self.subRoutine = subRoutine
        self.index = index
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        let subRoutineCheckIcon = subRoutine.isDone ? BitnagilIcon.checkedCircleSmallIcon : BitnagilIcon.uncheckedCircleSmallIcon
        subRoutineCheckButton.setImage(subRoutineCheckIcon, for: .normal)
        subRoutineCheckButton.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                var updatedSubRoutine = self.subRoutine
                updatedSubRoutine.isDone.toggle()
                self.subRoutine = updatedSubRoutine
                self.delegate?.subRoutineView(self, didTapSubRoutine: self.index)
            },
            for: .touchUpInside)

        subRoutineLabel.text = subRoutine.title
        subRoutineLabel.font = BitnagilFont(style: .body2, weight: .medium).font
        subRoutineLabel.textColor = BitnagilColor.gray40
        subRoutineLabel.numberOfLines = 0
    }

    private func configureLayout() {
        addSubview(subRoutineView)
        subRoutineView.addSubview(subRoutineCheckButton)
        subRoutineView.addSubview(subRoutineLabel)

        subRoutineCheckButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalTo(subRoutineLabel)
            make.size.equalTo(Layout.subRoutineCheckButtonSize)
        }

        subRoutineLabel.snp.makeConstraints { make in
            make.leading.equalTo(subRoutineCheckButton.snp.trailing).offset(Layout.subRoutineLabelLeadingSpacing)
            make.trailing.equalToSuperview()
            make.verticalEdges.equalToSuperview()
        }

        subRoutineView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(Layout.subRoutineViewHeight)
        }
    }

    func updateSubRoutineState() {
        let subRoutineCheckIcon = subRoutine.isDone ? BitnagilIcon.checkedCircleSmallIcon : BitnagilIcon.uncheckedCircleSmallIcon
        subRoutineCheckButton.setImage(subRoutineCheckIcon, for: .normal)
    }
}
