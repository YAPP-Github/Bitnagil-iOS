//
//  OnboardingChoiceButton.swift
//  Presentation
//
//  Created by 최정인 on 7/9/25.
//

import UIKit

final class OnboardingChoiceButton: UIButton {

    private enum Layout {
        static let cornerRadius: CGFloat = 12
        static let horizontalMargin: CGFloat = 20
        static let stackViewSpacing: CGFloat = 2
        static let mainLabelHeight: CGFloat = 28
        static let subLabelHeight: CGFloat = 20
    }

    private let stackView = UIStackView()
    private let mainLabel = UILabel()
    private var subLabel: UILabel? = nil

    private var isChecked: Bool = false {
        didSet {
            updateButtonAttribute()
        }
    }

    private var onboardingChoice: OnboardingChoiceProtocol
    init(onboardingChoice: OnboardingChoiceProtocol) {
        self.onboardingChoice = onboardingChoice
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()
        updateButtonAttribute()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        backgroundColor = .white
        layer.borderWidth = 1
        layer.cornerRadius = Layout.cornerRadius

        stackView.do {
            $0.axis = .vertical
            $0.alignment = .leading
            $0.spacing = Layout.stackViewSpacing
            $0.isUserInteractionEnabled = false
        }

        guard let subTitle = onboardingChoice.subTitle else {
            mainLabel.do {
                $0.text = onboardingChoice.mainTitle
                $0.font = BitnagilFont(style: .body1, weight: .regular).font
                $0.textColor = BitnagilColor.gray50
            }
            return
        }

        mainLabel.do {
            $0.text = onboardingChoice.mainTitle
            $0.font = BitnagilFont(style: .subtitle1, weight: .semiBold).font
            $0.textColor = BitnagilColor.gray50
        }

        subLabel = UILabel().then {
            $0.text = subTitle
            $0.font = BitnagilFont(style: .body2, weight: .regular).font
            $0.textColor = BitnagilColor.gray50
        }
    }

    private func configureLayout() {
        addSubview(stackView)
        stackView.addArrangedSubview(mainLabel)
        if let subLabel {
            stackView.addArrangedSubview(subLabel)
            mainLabel.snp.makeConstraints { make in
                make.height.equalTo(Layout.mainLabelHeight)
            }
            subLabel.snp.makeConstraints { make in
                make.height.equalTo(Layout.subLabelHeight)
            }
        }

        stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Layout.horizontalMargin)
            make.centerY.equalToSuperview()
        }
    }

    private func updateButtonAttribute() {
        backgroundColor = isChecked ? BitnagilColor.lightBlue75 : .white
        layer.borderColor = (isChecked ? BitnagilColor.lightBlue200 : .white)?.cgColor
        mainLabel.textColor = isChecked ? BitnagilColor.navy500 : BitnagilColor.gray50
        subLabel?.textColor = isChecked ? BitnagilColor.navy500 : BitnagilColor.gray50
    }

    func updateButtonState(isChecked: Bool) {
        self.isChecked = isChecked
    }
}
