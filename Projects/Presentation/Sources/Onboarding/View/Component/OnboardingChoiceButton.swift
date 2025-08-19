//
//  OnboardingChoiceButton.swift
//  Presentation
//
//  Created by 최정인 on 7/9/25.
//

import SnapKit
import UIKit

final class OnboardingChoiceButton: UIButton {
    private enum Layout {
        static let cornerRadius: CGFloat = 12
        static let horizontalMargin: CGFloat = 20
        static let stackViewSpacing: CGFloat = 2
        static let mainLabelHeight: CGFloat = 24
        static let subLabelHeight: CGFloat = 20
        static let checkedIconTrailingSpacing: CGFloat = 20
        static let checkedIconSize: CGFloat = 28
    }

    private let stackView = UIStackView()
    private let mainLabel = UILabel()
    private var subLabel: UILabel? = nil
    private let checkedIcon = UIImageView()

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
        backgroundColor = BitnagilColor.gray99
        layer.masksToBounds = true
        layer.cornerRadius = Layout.cornerRadius

        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = Layout.stackViewSpacing
        stackView.isUserInteractionEnabled = false

        mainLabel.text = onboardingChoice.title
        mainLabel.font = BitnagilFont(style: .body1, weight: .semiBold).font
        mainLabel.textColor = BitnagilColor.gray50

        if let subTitle = onboardingChoice.subTitle {
            subLabel = UILabel()
            subLabel?.text = subTitle
            subLabel?.font = BitnagilFont(style: .body2, weight: .medium).font
            subLabel?.textColor = BitnagilColor.gray50
        }

        checkedIcon.image = BitnagilIcon.orangeCheckedCircleIcon
        checkedIcon.isHidden = true
    }

    private func configureLayout() {
        addSubview(stackView)
        addSubview(checkedIcon)
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

        checkedIcon.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Layout.checkedIconTrailingSpacing)
            make.size.equalTo(Layout.checkedIconSize)
            make.centerY.equalToSuperview()
        }
    }

    private func updateButtonAttribute() {
        backgroundColor = isChecked ? BitnagilColor.orange50 : BitnagilColor.gray99
        mainLabel.textColor = isChecked ? BitnagilColor.orange500 : BitnagilColor.gray50
        subLabel?.textColor = isChecked ? BitnagilColor.orange500 : BitnagilColor.gray50
        checkedIcon.isHidden = !isChecked
    }

    func updateButtonState(isChecked: Bool) {
        self.isChecked = isChecked
    }
}
