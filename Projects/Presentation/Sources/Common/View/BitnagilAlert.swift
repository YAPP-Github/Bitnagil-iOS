//
//  BitnagilAlert.swift
//  Presentation
//
//  Created by 이동현 on 8/2/25.
//

import SnapKit
import UIKit

final class BitnagilAlert: UIViewController {
    private enum Layout {
        static let horizontalMargin: CGFloat = 24
        static let contentViewHorizontalSpacing: CGFloat = 44
        static let contentViewHorizontalHeight: CGFloat = 180
        static let titleTopSpacing: CGFloat = 20
        static let titleHeight: CGFloat = 28
        static let contentTopSpacing: CGFloat = 6
        static let contentHeight: CGFloat = 40
        static let buttonTopSpacing: CGFloat = 18
        static let buttonHeight: CGFloat = 48
        static let confirmButtonLeadingSpacing: CGFloat = 12
        static let buttonBottomSpacing: CGFloat = 20
    }

    private let dimmedView = UIView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let contentLabel = UILabel()
    private let cancelButton = UIButton()
    private let confirmButton = UIButton()
    private var cancelHandler: (() -> Void)?
    private var confirmHandler: (() -> Void)?

    init(
        title: String,
        content: String,
        cancelButtonTitle: String,
        confirmButtonTitle: String,
        cancelHandler: (() -> Void)?,
        confirmHandler: (() -> Void)?
    ) {
        super.init(nibName: nil, bundle: nil)

        self.cancelHandler = cancelHandler
        self.confirmHandler = confirmHandler
        titleLabel.text = title
        contentLabel.attributedText = BitnagilFont(style: .body2, weight: .medium).attributedString(text: content)
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
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true

        titleLabel.font = BitnagilFont(style: .subtitle1, weight: .semiBold).font
        titleLabel.textColor = BitnagilColor.gray10

        contentLabel.textColor = BitnagilColor.gray40
        contentLabel.numberOfLines = 2

        cancelButton.backgroundColor = BitnagilColor.gray97
        cancelButton.setTitleColor(BitnagilColor.gray40, for: .normal)
        confirmButton.backgroundColor = BitnagilColor.gray10
        confirmButton.setTitleColor(.white, for: .normal)
        [cancelButton, confirmButton].forEach {
            $0.titleLabel?.font = BitnagilFont(style: .body2, weight: .medium).font
            $0.layer.cornerRadius = 12
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

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Layout.titleTopSpacing)
            make.horizontalEdges.equalToSuperview().inset(Layout.horizontalMargin)
            make.height.equalTo(Layout.titleHeight)
        }

        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Layout.contentTopSpacing)
            make.horizontalEdges.equalToSuperview().inset(Layout.horizontalMargin)
            make.height.equalTo(Layout.contentHeight)
        }

        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(Layout.buttonTopSpacing)
            make.leading.equalToSuperview().offset(Layout.horizontalMargin)
            make.height.equalTo(Layout.buttonHeight)
            make.bottom.equalToSuperview().inset(Layout.buttonBottomSpacing)
        }

        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(Layout.buttonTopSpacing)
            make.leading.equalTo(cancelButton.snp.trailing).offset(Layout.confirmButtonLeadingSpacing)
            make.trailing.equalToSuperview().inset(Layout.horizontalMargin)
            make.height.equalTo(Layout.buttonHeight)
            make.width.equalTo(cancelButton)
            make.bottom.equalToSuperview().inset(Layout.buttonBottomSpacing)
        }
    }

    @objc private func didTapDimmedView() {
        dismiss(animated: false)
    }
}
