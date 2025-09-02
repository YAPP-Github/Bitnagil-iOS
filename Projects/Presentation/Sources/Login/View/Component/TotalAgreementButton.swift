//
//  TotalAgreementButton.swift
//  Presentation
//
//  Created by 최정인 on 7/7/25.
//

import SnapKit
import UIKit

final class TotalAgreementButton: UIButton {
    private enum Layout {
        static let cornerRadius: CGFloat = 12
        static let checkIconSize: CFloat = 24
        static let stackViewSpacing: CGFloat = 16
    }

    private let stackView = UIStackView()
    private let checkButton = UIImageView()
    private let buttonLabel = UILabel()

    private var enableState: Bool = false {
        didSet {
            updateButtonAttribute()
        }
    }

    init() {
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()
        updateButtonAttribute()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        backgroundColor = BitnagilColor.gray99
        layer.cornerRadius = Layout.cornerRadius

        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = Layout.stackViewSpacing
        stackView.isUserInteractionEnabled = false

        checkButton.image = BitnagilIcon.checkIcon
        checkButton.tintColor = BitnagilColor.gray90
        checkButton.contentMode = .scaleAspectFit

        buttonLabel.text = "전체동의"
        buttonLabel.textColor = BitnagilColor.gray50
        buttonLabel.font = BitnagilFont(style: .subtitle1, weight: .semiBold).font
    }

    private func configureLayout() {
        addSubview(stackView)
        stackView.addArrangedSubview(checkButton)
        stackView.addArrangedSubview(buttonLabel)

        stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Layout.stackViewSpacing)
            make.centerY.equalToSuperview()
        }

        checkButton.snp.makeConstraints { make in
            make.size.equalTo(Layout.checkIconSize)
        }
    }

    private func updateButtonAttribute() {
        backgroundColor = enableState ? BitnagilColor.orange50 : BitnagilColor.gray99
        checkButton.tintColor = enableState ? BitnagilColor.orange500 : BitnagilColor.gray90
        buttonLabel.textColor = enableState ? BitnagilColor.orange500 : BitnagilColor.gray50
    }

    func updateButtonState(enableState: Bool) {
        self.enableState = enableState
    }
}
