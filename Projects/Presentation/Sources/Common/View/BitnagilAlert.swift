//
//  BitnagilAlert.swift
//  Presentation
//
//  Created by 이동현 on 8/2/25.
//

import SnapKit
import UIKit

final class BitnagilAlert: UIViewController {
    enum AlertType {
        case withImage
        case plainText
    }

    private enum Layout {
        static let contentViewHorizontalSpacing: CGFloat = 39
        static let contentViewHorizontalHeight: CGFloat = 154
        static let imageSize: CGFloat = 55
        static let imageTopSpacing: CGFloat = 24
        static let titleTopSpacing: CGFloat = 18
        static let titleHeight: CGFloat = 30
        static let contentTopSpacing: CGFloat = 2
        static let contentHeight: CGFloat = 18
        static let buttonTopSpacing: CGFloat = 18
        static let buttonHorizontalSpacing: CGFloat = 20
        static let buttonHeight: CGFloat = 44
        static let confirmButtonLeadingSpacing: CGFloat = 8
        static let buttonBottomSpacing: CGFloat = 24
    }

    private let dimmedView = UIView()
    private let contentView = UIView()
    private let alertImageView = UIImageView()
    private let titleLabel = UILabel()
    private let contentLabel = UILabel()
    private let cancelButton = UIButton()
    private let confirmButton = UIButton()
    private let alertType: AlertType
    private var cancelHandler: (() -> Void)?
    private var confirmHandler: (() -> Void)?

    init(
        alertType: AlertType,
        title: String,
        content: String,
        cancelButtonTitle: String,
        confirmButtonTitle: String,
        cancelHandler: (() -> Void)?,
        confirmHandler: (() -> Void)?
    ) {
        self.alertType = alertType
        super.init(nibName: nil, bundle: nil)

        self.cancelHandler = cancelHandler
        self.confirmHandler = confirmHandler
        titleLabel.text = title
        contentLabel.text = content
        cancelButton.setTitle(cancelButtonTitle, for: .normal)
        confirmButton.setTitle(confirmButtonTitle, for: .normal)

        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        view.backgroundColor = .clear

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapDimmedView))
        dimmedView.addGestureRecognizer(tapGesture)
        dimmedView.backgroundColor = .black
        dimmedView.alpha = 0.7

        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true

        alertImageView.image = BitnagilIcon.exclamationFilledIcon
        titleLabel.font = BitnagilFont(style: .title2, weight: .bold).font
        contentLabel.font = BitnagilFont(style: .caption1, weight: .regular).font

        cancelButton.backgroundColor = .white
        cancelButton.setTitleColor(BitnagilColor.navy500, for: .normal)
        confirmButton.backgroundColor = BitnagilColor.navy500
        confirmButton.setTitleColor(.white, for: .normal)
        [cancelButton, confirmButton].forEach {
            $0.titleLabel?.font = BitnagilFont(style: .subtitle1, weight: .bold).font
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = 8
            $0.layer.masksToBounds = true
        }

        cancelButton.addAction(
            UIAction { [weak self] _ in
                self?.cancelHandler?()
                self?.dismiss(animated: false)
            },
            for: .touchUpInside)

        confirmButton.addAction(
            UIAction { [weak self] _ in
                self?.confirmHandler?()
                self?.dismiss(animated: false)
            },
            for: .touchUpInside)
    }

    private func configureLayout() {
        view.addSubview(dimmedView)
        view.addSubview(contentView)

        contentView.addSubview(titleLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(cancelButton)
        contentView.addSubview(confirmButton)

        dimmedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(Layout.contentViewHorizontalSpacing)
            make.height.equalTo(Layout.contentViewHorizontalHeight).priority(.medium)
        }

        if alertType == .withImage {
            contentView.addSubview(alertImageView)
            alertImageView.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(Layout.imageTopSpacing)
                make.centerX.equalToSuperview()
                make.size.equalTo(Layout.imageSize)
            }

            titleLabel.snp.makeConstraints { make in
                make.top.equalTo(alertImageView.snp.bottom).offset(Layout.titleTopSpacing)
                make.centerX.equalToSuperview()
                make.height.equalTo(Layout.titleHeight)
            }
        } else {
            titleLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(Layout.titleTopSpacing)
                make.centerX.equalToSuperview()
                make.height.equalTo(Layout.titleHeight)
            }
        }

        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Layout.contentTopSpacing)
            make.centerX.equalToSuperview()
            make.height.equalTo(Layout.contentHeight)
        }

        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(Layout.buttonTopSpacing)
            make.leading.equalToSuperview().offset(Layout.buttonHorizontalSpacing)
            make.height.equalTo(Layout.buttonHeight)
            make.bottom.equalToSuperview().inset(Layout.buttonBottomSpacing)
        }

        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(Layout.buttonTopSpacing)
            make.leading.equalTo(cancelButton.snp.trailing).offset(Layout.confirmButtonLeadingSpacing)
            make.trailing.equalToSuperview().inset(Layout.buttonHorizontalSpacing)
            make.height.equalTo(Layout.buttonHeight)
            make.width.equalTo(cancelButton)
            make.bottom.equalToSuperview().inset(Layout.buttonBottomSpacing)
        }
    }

    @objc private func didTapDimmedView() {
        dismiss(animated: false)
    }
}
