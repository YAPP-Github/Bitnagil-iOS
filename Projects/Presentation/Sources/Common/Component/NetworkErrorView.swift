//
//  NetworkErrorView.swift
//  Presentation
//
//  Created by 이동현 on 2/17/26.
//

import SnapKit
import UIKit

final class NetworkErrorView: UIView {
    private enum Layout {
        static let contentViewWidth: CGFloat = 204
        static let contentViewHeight: CGFloat = 215
        static let errorImageSize: CGFloat = 40
        static let boldtitleLabelTopSpacing: CGFloat = 21
        static let boldTitleLabelHeight: CGFloat = 30
        static let mediumTitleLabelTopSpacing: CGFloat = 2
        static let mediumTitleLabelHeight: CGFloat = 24
        static let retryButtonWidth: CGFloat = 113
        static let retryButtonHeight: CGFloat = 48
    }

    private let contentView = UIView()
    private let errorImageView = UIImageView()
    private let boldTitleLabel = UILabel()
    private let mediumTitleLabel = UILabel()
    private let retryButton = UIButton()
    var onRetry: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        backgroundColor = .white
        contentView.backgroundColor = .white

        errorImageView.image = BitnagilIcon
            .networkErrorIcon?
            .withRenderingMode(.alwaysOriginal)

        boldTitleLabel.text = "네트워크가 불안정해요"
        boldTitleLabel.font = BitnagilFont.init(style: .title2, weight: .bold).font
        boldTitleLabel.textColor = .black
        boldTitleLabel.textAlignment = .center

        mediumTitleLabel.text = "연결 확인 후 다시 시도해 주세요."
        mediumTitleLabel.font = BitnagilFont.init(style: .body1, weight: .medium).font
        mediumTitleLabel.textColor = BitnagilColor.gray40
        mediumTitleLabel.textAlignment = .center

        retryButton.tintColor = BitnagilColor.gray10
        retryButton.backgroundColor = BitnagilColor.gray10
        retryButton.setTitleColor(.white, for: .normal)
        retryButton.setTitle("다시 시도", for: .normal)
        retryButton.titleLabel?.font = BitnagilFont.init(style: .body2, weight: .medium).font
        retryButton.layer.cornerRadius = 12
        retryButton.layer.masksToBounds = true
        retryButton.addAction(UIAction { [weak self] _ in
            self?.onRetry?()
        }, for: .touchUpInside)
    }

    private func configureLayout() {
        addSubview(contentView)
        contentView.addSubview(errorImageView)
        contentView.addSubview(boldTitleLabel)
        contentView.addSubview(mediumTitleLabel)
        contentView.addSubview(retryButton)

        contentView.snp.makeConstraints { make in
            make.width.equalTo(Layout.contentViewWidth)

            make.height.equalTo(Layout.contentViewHeight)

            make.center.equalToSuperview()
        }

        errorImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()

            make.size.equalTo(Layout.errorImageSize)

            make.top.equalToSuperview()
        }

        boldTitleLabel.snp.makeConstraints { make in
            make.top
                .equalTo(errorImageView.snp.bottom)
                .offset(Layout.boldtitleLabelTopSpacing)

            make.height.equalTo(Layout.boldTitleLabelHeight)

            make.centerX.equalToSuperview()
        }

        mediumTitleLabel.snp.makeConstraints { make in
            make.top
                .equalTo(boldTitleLabel.snp.bottom)
                .offset(Layout.mediumTitleLabelTopSpacing)

            make.height.equalTo(Layout.mediumTitleLabelHeight)

            make.centerX.equalToSuperview()
        }

        retryButton.snp.makeConstraints { make in
            make.width.equalTo(Layout.retryButtonWidth)

            make.height.equalTo(Layout.retryButtonHeight)

            make.centerX.equalToSuperview()

            make.bottom.equalToSuperview()
        }
    }
}
