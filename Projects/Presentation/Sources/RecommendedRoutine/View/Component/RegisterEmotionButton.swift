//
//  RegisterEmotionButton.swift
//  Presentation
//
//  Created by 최정인 on 7/12/25.
//

import SnapKit
import UIKit

final class RegisterEmotionButton: UIButton {

    private enum Layout {
        static let borderWith: CGFloat = 1
        static let cornerRadius: CGFloat = 12
        static let plusIconImageSize: CGFloat = 8
        static let plusIconSize: CGFloat = 20
        static let plusIconLeadingSpacing: CGFloat = 24
        static let buttonLabelLeadingSpacing: CGFloat = 10
    }

    private let plusIcon = UIImageView()
    private let buttonLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        layer.borderWidth = Layout.borderWith
        layer.cornerRadius = Layout.cornerRadius
        layer.borderColor = BitnagilColor.navy100?.cgColor

        plusIcon.contentMode = .center
        plusIcon.image = BitnagilIcon.plusIcon?
            .resizeAspectFit(to: CGSize(width: Layout.plusIconImageSize, height: Layout.plusIconImageSize))?
            .withRenderingMode(.alwaysTemplate)
        plusIcon.tintColor = BitnagilColor.navy400

        buttonLabel.text = "오늘의 감정 루틴 추천받기"
        buttonLabel.font = BitnagilFont(style: .body2, weight: .medium).font
        buttonLabel.textColor = BitnagilColor.navy400
    }

    private func configureLayout() {
        addSubview(plusIcon)
        addSubview(buttonLabel)

        plusIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(Layout.plusIconLeadingSpacing)
            make.size.equalTo(Layout.plusIconSize)
        }

        buttonLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(plusIcon.snp.trailing).offset(Layout.buttonLabelLeadingSpacing)
        }
    }
}
