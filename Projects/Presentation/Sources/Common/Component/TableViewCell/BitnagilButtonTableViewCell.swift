//
//  BitnagilButtonTableViewCell.swift
//  Presentation
//
//  Created by 이동현 on 7/30/25.
//

import SnapKit
import UIKit

protocol BitnagilButtonTableViewCellDelegate: AnyObject {
    func bitnagilButtonTableViewCellDidTapButton(_ sender: BitnagilButtonTableViewCell)
}

final class BitnagilButtonTableViewCell: BitnagilBaseTableViewCell {
    private enum Layout {
        static let buttonTrailingSpacing: CGFloat = 20
        static let buttonHeight: CGFloat = 30
        static let buttonPadding: CGFloat = 10
        static let buttonCornerRadius: CGFloat = 4
    }

    private let button = UIButton()
    private var buttonWidthConstraint: Constraint?
    weak var delegate: BitnagilButtonTableViewCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(
        title: String,
        buttonTitle: String,
        isButtonEnabled: Bool
    ) {
        super.configure(title: title)

        let font = BitnagilFont.init(style: .body2, weight: .semiBold).font
        let textAttribute = [NSAttributedString.Key.font: font]
        let textWidth = (buttonTitle as NSString).size(withAttributes: textAttribute).width
        let buttonWidth = textWidth + Layout.buttonPadding * 2
        
        buttonWidthConstraint?.update(offset: buttonWidth)
        button.setTitle(buttonTitle, for: .normal)
        button.isEnabled = isButtonEnabled

        if isButtonEnabled {
            button.backgroundColor = BitnagilColor.lightBlue100
            button.setTitleColor(BitnagilColor.navy500, for: .normal)
        } else {
            button.backgroundColor = BitnagilColor.gray98
            button.setTitleColor(BitnagilColor.gray70, for: .disabled)
        }
    }

    override func configureAttribute() {
        super.configureAttribute()

        button.titleLabel?.font = BitnagilFont.init(style: .body2, weight: .semiBold).font
        button.layer.cornerRadius = Layout.buttonCornerRadius
        button.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                self.delegate?.bitnagilButtonTableViewCellDidTapButton(self)
            },
            for: .touchUpInside)
    }

    override func configureLayout() {
        super.configureLayout()
        
        contentView.addSubview(button)

        button.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(Layout.buttonTrailingSpacing)
            make.height.equalTo(Layout.buttonHeight)
            buttonWidthConstraint = make.width
                .equalTo(Layout.buttonPadding)
                .constraint
        }
    }
}
