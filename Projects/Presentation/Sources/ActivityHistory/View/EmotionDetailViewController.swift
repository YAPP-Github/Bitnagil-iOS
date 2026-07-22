//
//  EmotionDetailViewController.swift
//  Presentation
//
//  Created by 최정인 on 7/7/26.
//

import Kingfisher
import SnapKit
import UIKit

final class EmotionDetailViewController: UIViewController {
    private enum Layout {
        static let horizontalMargin: CGFloat = 24
        static let headerStackViewSpacing: CGFloat = 10
        static let headerStackViewTopSpacing: CGFloat = 18
        static let headerStackViewTrailingSpacing: CGFloat = 4
        static let headerStackViewHeight: CGFloat = 44
        static let closeButtonSize: CGFloat = 44
        static let closeButtonImageSize: CGFloat = 24
        static let emotionImageViewTopSpacing: CGFloat = 30
        static let emotionImageViewWidth: CGFloat = 327
        static let emotionImageViewHeight: CGFloat = 198
    }

    private let date: Date
    private let emotion: EmotionMarble

    private let headerStackView = UIStackView()
    private let dateLabel = UILabel()
    private let closeButtonImage = UIImageView()
    private let closeButton = UIButton()
    private let descriptionLabel = UILabel()
    private let emotionImageView = UIImageView()
    var onDismiss: (() -> Void)?

    init(date: Date, emotion: EmotionMarble) {
        self.date = date
        self.emotion = emotion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAttribute()
        configureLayout()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onDismiss?()
    }

    private func configureAttribute() {
        view.backgroundColor = BitnagilColor.gray99

        headerStackView.axis = .horizontal
        headerStackView.alignment = .center
        headerStackView.spacing = Layout.headerStackViewSpacing

        dateLabel.text = "\(date.convertToString(dateType: .yearMonthDateLong))의 감정"
        dateLabel.font = BitnagilFont(style: .title3, weight: .semiBold).font
        dateLabel.textColor = BitnagilColor.gray10

        descriptionLabel.attributedText = BitnagilFont(style: .body2, weight: .medium).attributedString(text: emotion.marble.emotionDescription)
        descriptionLabel.numberOfLines = 2
        descriptionLabel.font = BitnagilFont(style: .body2, weight: .medium).font
        descriptionLabel.textColor = BitnagilColor.gray40

        closeButtonImage.image = BitnagilIcon.closeIcon
        closeButtonImage.contentMode = .scaleAspectFit
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)

        emotionImageView.contentMode = .scaleAspectFit
        if let url = URL(string: emotion.imageUrl) {
            emotionImageView.kf.setImage(with: url)
        }
    }

    private func configureLayout() {
        let spacerView = UIView()
        [dateLabel, spacerView, closeButton].forEach {
            headerStackView.addArrangedSubview($0)
        }
        closeButton.addSubview(closeButtonImage)

        [headerStackView, descriptionLabel, emotionImageView].forEach {
            view.addSubview($0)
        }

        headerStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Layout.headerStackViewTopSpacing)
            make.leading.equalToSuperview().offset(Layout.horizontalMargin)
            make.trailing.equalToSuperview().inset(Layout.headerStackViewTrailingSpacing)
            make.height.equalTo(Layout.headerStackViewHeight)
        }

        closeButton.snp.makeConstraints { make in
            make.size.equalTo(Layout.closeButtonSize)
        }

        closeButtonImage.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(Layout.closeButtonImageSize)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(headerStackView.snp.bottom)
            make.leading.equalToSuperview().offset(Layout.horizontalMargin)
        }

        emotionImageView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(Layout.emotionImageViewTopSpacing)
            make.horizontalEdges.equalToSuperview().inset(Layout.horizontalMargin)
            make.width.equalTo(Layout.emotionImageViewWidth)
            make.height.equalTo(Layout.emotionImageViewHeight)
        }
    }

    @objc private func didTapCloseButton() {
        dismiss(animated: true)
    }
}
