//
//  HomeRegisterEmotionButton.swift
//  Presentation
//
//  Created by 최정인 on 7/21/25.
//

import UIKit

final class HomeRegisterEmotionButton: UIButton {

    private enum Layout {
        static let chevronIconSize: CGFloat = 12
        static let chevronIconLeadingSpacing: CGFloat = 4
        static let buttonLabelLeadingSpacing: CGFloat = 20
        static let buttonLabelHeight: CGFloat = 20
    }

    private let buttonLabel = UILabel()
    private let chevronIcon = UIImageView()

    init() {
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureAttribute() {
        buttonLabel.text = "감정구슬 기록하기"
        buttonLabel.font = BitnagilFont(style: .caption1, weight: .medium).font
        buttonLabel.textColor = BitnagilColor.navy300

        chevronIcon.image = BitnagilIcon.chevronIcon(direction: .right)?
            .resize(to: CGSize(width: Layout.chevronIconSize, height: Layout.chevronIconSize))?
            .withRenderingMode(.alwaysTemplate)
        chevronIcon.tintColor = BitnagilColor.navy300
    }

    private func configureLayout() {
        addSubview(buttonLabel)
        addSubview(chevronIcon)

        buttonLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(Layout.buttonLabelLeadingSpacing)
            make.height.equalTo(Layout.buttonLabelHeight)
        }

        chevronIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(buttonLabel.snp.trailing).offset(Layout.chevronIconLeadingSpacing)
        }
    }
}
