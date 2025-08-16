//
//  RoutineNameContentView.swift
//  Presentation
//
//  Created by 이동현 on 8/11/25.
//

import SnapKit
import UIKit

final class RoutineNameContentView: UIView, RoutineCreationExpandable {
    private enum Layout {
        static let edgeSpacing: CGFloat = 19
        static let numberImageSize: CGFloat = 20
        static let numberCenterYFromTextField: CGFloat = 2.5
        static let textFieldLeadingSpacing: CGFloat = 12
        static let textFieldHeight: CGFloat = 20
        static let divideLineHeight: CGFloat = 1.3
        static let textFieldTopSpacing: CGFloat = 23
        static let checkButtonImageViewTopSpacing: CGFloat = 24
        static let checkButtonImageViewSize: CGFloat = 18
        static let checkButtonLabelHeight: CGFloat = 20
        static let checkButtonLabelTrailingSpacing: CGFloat = 6
        static let foldedHeight: CGFloat = 0
    }

    enum Action {
        case subroutineChanged(index: Int, text: String)
        case deleteAllSubroutines
    }

    struct Dependency {
        let subRoutines: [String]
    }

    private let oneImageView = UIImageView()
    private let twoImageView = UIImageView()
    private let threeImageView = UIImageView()
    private let subRoutineTextField1 = UITextField()
    private let subRoutineTextField2 = UITextField()
    private let subRoutineTextField3 = UITextField()
    private let divideLine1 = UIImageView()
    private let divideLine2 = UIImageView()
    private let divideLine3 = UIImageView()
    private let checkButtonLabel = UILabel()
    private let checkButtonImageView = UIImageView()
    private let checkButton = UIButton()
    var heightConstraint: Constraint?
    var action: ((Action) -> Void)?

    private var isExpanded = true // 초기 상태 추적

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
        guard !dependency.subRoutines.isEmpty else { return }

        let subRoutines = dependency.subRoutines
        let subRoutineTextFields = [
            subRoutineTextField1,
            subRoutineTextField2,
            subRoutineTextField3]
        let minCount = min(subRoutines.count, subRoutineTextFields.count)

        zip(subRoutines, subRoutineTextFields).prefix(minCount).forEach {
            $1.text = $0
        }

        if dependency.subRoutines.filter({ !$0.isEmpty }).isEmpty {
            checkButtonImageView.image = BitnagilIcon.checkedIcon
        } else {
            checkButtonImageView.image = BitnagilIcon.uncheckedIcon
        }
    }

    private func configureAttribute() {
        oneImageView.image = BitnagilIcon.oneIcon
        twoImageView.image = BitnagilIcon.twoIcon
        threeImageView.image = BitnagilIcon.threeIcon

        let placeholders = [
            "ex) 일어나자마자 이불 개기",
            "ex) 일어나서 찬물 마시기",
            "ex) 양치하기"]

        let textFields = [
            subRoutineTextField1,
            subRoutineTextField2,
            subRoutineTextField3]

        zip(textFields, placeholders)
            .enumerated()
            .forEach {
                let index = $0
                let (textField, placeholder) = $1

                let attributes: [NSAttributedString.Key: Any] = [
                    .font: BitnagilFont(style: .body2, weight: .medium).font,
                    .foregroundColor: BitnagilColor.gray90 ?? .systemGray
                ]

                textField.delegate = self
                textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
                textField.font = BitnagilFont(style: .body2, weight: .medium).font
                textField.textColor = BitnagilColor.gray30
                textField.tag = index
                textField.returnKeyType = .done
                textField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
            }

        divideLine1.image = BitnagilIcon.divideLineIcon
        divideLine2.image = BitnagilIcon.divideLineIcon
        divideLine3.image = BitnagilIcon.divideLineIcon

        checkButtonLabel.text = "세부루틴 설정 안함"
        checkButtonLabel.font = BitnagilFont.init(style: .body2, weight: .medium).font

        checkButtonImageView.layer.cornerRadius = 4
        checkButtonImageView.layer.masksToBounds = true
        checkButtonImageView.layer.borderWidth = 1
        checkButtonImageView.backgroundColor = .white
        checkButtonImageView.layer.borderColor = BitnagilColor.gray95?.cgColor
        checkButton.addAction(
            UIAction { [weak self] _ in
                self?.action?(.deleteAllSubroutines)
            },
            for: .touchUpInside)
    }

    private func configureLayout() {
        addSubview(oneImageView)
        addSubview(twoImageView)
        addSubview(threeImageView)
        addSubview(subRoutineTextField1)
        addSubview(subRoutineTextField2)
        addSubview(subRoutineTextField3)
        addSubview(divideLine1)
        addSubview(divideLine2)
        addSubview(divideLine3)
        addSubview(checkButtonLabel)
        addSubview(checkButtonImageView)
        addSubview(checkButton)

        self.snp.makeConstraints { make in
            heightConstraint = make.height.equalTo(Layout.foldedHeight).constraint
        }

        oneImageView.snp.makeConstraints { make in
            make.centerY.equalTo(subRoutineTextField1).offset(Layout.numberCenterYFromTextField)
            make.leading.equalToSuperview().offset(Layout.edgeSpacing)
            make.size.equalTo(Layout.numberImageSize).priority(999)
        }

        twoImageView.snp.makeConstraints { make in
            make.centerY.equalTo(subRoutineTextField2).offset(Layout.numberCenterYFromTextField)
            make.leading.equalToSuperview().offset(Layout.edgeSpacing)
            make.size.equalTo(Layout.numberImageSize).priority(999)
        }

        threeImageView.snp.makeConstraints { make in
            make.centerY.equalTo(subRoutineTextField3).offset(Layout.numberCenterYFromTextField)
            make.leading.equalToSuperview().offset(Layout.edgeSpacing)
            make.size.equalTo(Layout.numberImageSize).priority(999)
        }

        subRoutineTextField1.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Layout.edgeSpacing).priority(999)
            make.leading.equalTo(oneImageView.snp.trailing).offset(Layout.textFieldLeadingSpacing)
            make.trailing.equalToSuperview().offset(-Layout.edgeSpacing)
            make.height.equalTo(Layout.textFieldHeight).priority(999)
        }

        subRoutineTextField2.snp.makeConstraints { make in
            make.top.equalTo(divideLine1.snp.bottom).offset(Layout.textFieldTopSpacing)
            make.leading.equalTo(oneImageView.snp.trailing).offset(Layout.textFieldLeadingSpacing)
            make.trailing.equalToSuperview().offset(-Layout.edgeSpacing)
            make.height.equalTo(Layout.textFieldHeight).priority(999)
        }

        subRoutineTextField3.snp.makeConstraints { make in
            make.top.equalTo(divideLine2.snp.bottom).offset(Layout.textFieldTopSpacing)
            make.leading.equalTo(oneImageView.snp.trailing).offset(Layout.textFieldLeadingSpacing)
            make.trailing.equalToSuperview().offset(-Layout.edgeSpacing)
            make.height.equalTo(Layout.textFieldHeight).priority(999)
        }

        divideLine1.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(subRoutineTextField1)
            make.top.equalTo(subRoutineTextField1.snp.bottom)
            make.height.equalTo(Layout.divideLineHeight).priority(999)
        }

        divideLine2.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(subRoutineTextField2)
            make.top.equalTo(subRoutineTextField2.snp.bottom)
            make.height.equalTo(Layout.divideLineHeight).priority(999)
        }

        divideLine3.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(subRoutineTextField3)
            make.top.equalTo(subRoutineTextField3.snp.bottom)
            make.height.equalTo(Layout.divideLineHeight).priority(999)
        }

        checkButtonImageView.snp.makeConstraints { make in
            make.top.equalTo(divideLine3.snp.bottom).offset(Layout.checkButtonImageViewTopSpacing).priority(999)
            make.bottom.equalToSuperview().offset(-Layout.edgeSpacing).priority(999)
            make.trailing.equalToSuperview().offset(-Layout.edgeSpacing)
            make.size.equalTo(Layout.checkButtonImageViewSize).priority(999)
        }

        checkButtonLabel.snp.makeConstraints { make in
            make.trailing.equalTo(checkButtonImageView.snp.leading).offset(-Layout.checkButtonLabelTrailingSpacing)
            make.centerY.equalTo(checkButtonImageView)
        }

        checkButton.snp.makeConstraints { make in
            make.verticalEdges.equalTo(checkButtonImageView)
            make.leading.equalTo(checkButtonLabel.snp.leading)
            make.trailing.equalTo(checkButtonImageView.snp.trailing)
        }
    }

    @objc private func textFieldEditingChanged(_ sender: UITextField) {
        action?(.subroutineChanged(index: sender.tag, text: sender.text ?? ""))
    }
}

extension RoutineNameContentView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
