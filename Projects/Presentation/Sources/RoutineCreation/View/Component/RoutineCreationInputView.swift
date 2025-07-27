//
//  RoutineCreationInputView.swift
//  Presentation
//
//  Created by 이동현 on 7/20/25.
//

import SnapKit
import UIKit

/// 루틴 등록 화면 텍스트 입력 delegate
protocol RoutineCreationInputViewDelegate: AnyObject {
    /// 등록한 view를 삭제합니다.
    func routineCreationInputViewDidTapDeleteButton(_ sender: RoutineCreationInputView)

    /// 입력 중인 text를 반환합니다.
    func routineCreationInputView(_ sender: RoutineCreationInputView, didChangeText text: String)
}

final class RoutineCreationInputView: UIView {
    private enum Layout {
        static let textFieldLeadingOffset: CGFloat = 24
        static let textFieldTrailingInset: CGFloat = 51
        static let textFieldHeight: CGFloat = 20
        static let deleteButtonSize: CGFloat = 24
        static let deleteButtonTrailingInset: CGFloat = 8
    }

    private let textField = UITextField()
    private let deleteButton = UIButton()
    weak var delegate: RoutineCreationInputViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureAttribute()
        configureLayout()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        backgroundColor = BitnagilColor.gray99
        layer.cornerRadius = 12

        textField.delegate = self
        textField.textColor = .black
        textField.font = BitnagilFont.init(style: .body2, weight: .semiBold).font

        deleteButton.setImage(BitnagilIcon.deleteIcon, for: .normal)
        deleteButton.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                self.delegate?.routineCreationInputViewDidTapDeleteButton(self)
            }, for: .touchUpInside)
    }

    private func configureLayout() {
        addSubview(textField)
        addSubview(deleteButton)

        textField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Layout.textFieldLeadingOffset)
            make.trailing.equalToSuperview().inset(Layout.textFieldTrailingInset)
            make.centerY.equalToSuperview()
            make.height.equalTo(Layout.textFieldHeight)
        }

        deleteButton.snp.makeConstraints { make in
            make.size.equalTo(Layout.deleteButtonSize)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(Layout.deleteButtonTrailingInset)
        }
    }

    func configure(canDelete: Bool, placeholder: String?) {
        deleteButton.isHidden = !canDelete

        guard
            let placeholder,
            let placeholderColor = BitnagilColor.gray90
        else { return }

        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: placeholderColor,
                .font: BitnagilFont.init(style: .body2, weight: .semiBold).font])
    }

    func configure(title: String) {
        textField.text = title
    }
}

extension RoutineCreationInputView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text {
            delegate?.routineCreationInputView(self, didChangeText: text)
        }
        return true
    }
}
