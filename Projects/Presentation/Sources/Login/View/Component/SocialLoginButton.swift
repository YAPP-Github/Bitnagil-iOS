//
//  SocialLoginButton.swift
//  Presentation
//
//  Created by 최정인 on 7/6/25.
//

import SnapKit
import UIKit

final class SocialLoginButton: UIButton {

    private enum Layout {
        static let cornerRadius: CGFloat = 12
        static let iconSize: CFloat = 24
        static let stackViewSpacing: CGFloat = 8
    }

    enum SocialType {
        case kakao
        case apple

        var buttonColor: UIColor? {
            switch self {
            case .kakao: BitnagilColor.kakao
            case .apple: .black
            }
        }

        var buttonTextColor: UIColor? {
            switch self {
            case .kakao: .black
            case .apple: .white
            }
        }

        var iconImage: UIImage? {
            switch self {
            case .kakao: BitnagilIcon.kakaoIcon
            case .apple: BitnagilIcon.appleIcon
            }
        }

        var buttonTitle: String {
            switch self {
            case .kakao: "카카오로 시작하기"
            case .apple: "Apple로 시작하기"
            }
        }
    }

    private let socialType: SocialType
    private let stackView = UIStackView()
    private let iconImageView = UIImageView()
    private let buttonLabel = UILabel()

    init(socialType: SocialType) {
        self.socialType = socialType
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        backgroundColor = socialType.buttonColor
        layer.cornerRadius = Layout.cornerRadius

        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = Layout.stackViewSpacing
        stackView.isUserInteractionEnabled = false

        iconImageView.image = socialType.iconImage
        iconImageView.contentMode = .scaleAspectFit

        buttonLabel.text = socialType.buttonTitle
        buttonLabel.textColor = socialType.buttonTextColor
        buttonLabel.font = BitnagilFont(style: .button2, weight: .semiBold).font
    }

    private func configureLayout() {
        addSubview(stackView)
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(buttonLabel)

        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        iconImageView.snp.makeConstraints { make in
            make.size.equalTo(Layout.iconSize)
        }
    }
}
