//
//  SubRoutineView.swift
//  Presentation
//
//  Created by 최정인 on 7/18/25.
//

import UIKit

final class SubRoutineButton: UIButton {

    private enum Layout {
        static let checkButtonLeadingSpacing: CGFloat = 14
        static let checkButtonSize: CGFloat = 18
        static let routineLabelLeadingSpacing: CGFloat = 10
    }

    private let checkButton = UIImageView()
    private let routineLabel = UILabel()

    private var subRoutine: SubRoutine {
        didSet {
            updateAttribute()
        }
    }

    init(subRoutine: SubRoutine) {
        self.subRoutine = subRoutine
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        checkButton.image = BitnagilIcon.checkIcon
        checkButton.tintColor = subRoutine.isDone ? BitnagilColor.orange500 : BitnagilColor.gray96

        routineLabel.text = subRoutine.title
        routineLabel.font = BitnagilFont(style: .body2, weight: .medium).font
        routineLabel.textColor = BitnagilColor.gray20
    }

    private func configureLayout() {
        addSubview(checkButton)
        addSubview(routineLabel)

        checkButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(Layout.checkButtonLeadingSpacing)
            make.size.equalTo(Layout.checkButtonSize)
        }

        routineLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(checkButton.snp.trailing).offset(Layout.routineLabelLeadingSpacing)
        }
    }

    private func updateAttribute() {
        let isDone = subRoutine.isDone
        checkButton.tintColor = isDone ? BitnagilColor.orange500 : BitnagilColor.gray96
    }

    func updateState(isDone: Bool) {
        subRoutine.isDone = isDone
    }
}
