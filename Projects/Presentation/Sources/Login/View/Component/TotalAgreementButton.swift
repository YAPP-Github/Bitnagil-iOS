//
//  TotalAgreementButton.swift
//  Presentation
//
//  Created by 최정인 on 7/7/25.
//

import UIKit
import SnapKit

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

        stackView.do {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.spacing = Layout.stackViewSpacing
            $0.isUserInteractionEnabled = false
        }

        checkButton.do {
            $0.image = BitnagilIcon.checkIcon
            $0.tintColor = BitnagilColor.navy100
            $0.contentMode = .scaleAspectFit
        }

        buttonLabel.do {
            $0.text = "전체동의"
            $0.textColor = BitnagilColor.gray50
            $0.font = BitnagilFont(style: .subtitle1, weight: .semiBold).font
        }
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
        backgroundColor = enableState ? BitnagilColor.lightBlue75 : BitnagilColor.gray99
        checkButton.tintColor = enableState ? BitnagilColor.navy500 : BitnagilColor.navy100
        buttonLabel.textColor = enableState ? BitnagilColor.navy500 : BitnagilColor.gray50
    }

    func updateButtonState(enableState: Bool) {
        self.enableState = enableState
    }
}
