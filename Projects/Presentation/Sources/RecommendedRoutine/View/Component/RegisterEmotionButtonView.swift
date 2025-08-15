//
//  RegisterEmotionButtonView.swift
//  Presentation
//
//  Created by 최정인 on 8/15/25.
//

import SnapKit
import UIKit

protocol RegisterEmotionButtonViewDelegate: AnyObject {
    func registerEmotionButtonViewDidTapRegisterButton(_ sender: RegisterEmotionButtonView)
}

final class RegisterEmotionButtonView: UIView {
    private enum Layout {
        static let cornerRadius: CGFloat = 12
        static let emotionOrbImageViewLeadingSpacing: CGFloat = 13
        static let emotionOrbImageViewSize: CGFloat = 34
        static let registerEmotionLabelLeadingSpacing: CGFloat = 5
        static let registerEmotionButtonCornerRadius: CGFloat = 8
        static let registerEmotionButtonTrailingSpacing: CGFloat = 19
        static let registerEmotionButtonWidth: CGFloat = 74
        static let registerEmotionButtonHeight: CGFloat = 38
    }

    private let emotionOrbImageView = UIImageView()
    private let registerEmotionLabel = UILabel()
    private let registerEmotionButton = UIButton()
    weak var delegate: RegisterEmotionButtonViewDelegate?

    init() {
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureAttribute() {
        emotionOrbImageView.image = BitnagilGraphic.defaultEmotionGraphic
        emotionOrbImageView.contentMode = .scaleAspectFit

        registerEmotionLabel.text = "내 기분에 맞는 루틴 추천받기"
        registerEmotionLabel.font = BitnagilFont(style: .body2, weight: .semiBold).font
        registerEmotionLabel.textColor = .white

        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.baseBackgroundColor = BitnagilColor.orange500
        buttonConfiguration.background.cornerRadius = Layout.registerEmotionButtonCornerRadius
        buttonConfiguration.attributedTitle = AttributedString(
            "추천받기",
            attributes: .init([.font: BitnagilFont(style: .caption1, weight: .semiBold).font]))
        buttonConfiguration.baseForegroundColor = .white
        registerEmotionButton.configuration = buttonConfiguration
        registerEmotionButton.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                self.delegate?.registerEmotionButtonViewDidTapRegisterButton(self)
            },
            for: .touchUpInside)
    }

    private func configureLayout() {
        backgroundColor = BitnagilColor.gray10
        layer.masksToBounds = true
        layer.cornerRadius = Layout.cornerRadius

        [emotionOrbImageView, registerEmotionLabel, registerEmotionButton].forEach {
            addSubview($0)
        }

        emotionOrbImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Layout.emotionOrbImageViewLeadingSpacing)
            make.centerY.equalToSuperview()
            make.size.equalTo(Layout.emotionOrbImageViewSize)
        }

        registerEmotionLabel.snp.makeConstraints { make in
            make.leading.equalTo(emotionOrbImageView.snp.trailing).offset(Layout.registerEmotionLabelLeadingSpacing)
            make.centerY.equalToSuperview()
        }

        registerEmotionButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Layout.registerEmotionButtonTrailingSpacing)
            make.centerY.equalToSuperview()
            make.width.equalTo(Layout.registerEmotionButtonWidth)
            make.height.equalTo(Layout.registerEmotionButtonHeight)
        }
    }
}
