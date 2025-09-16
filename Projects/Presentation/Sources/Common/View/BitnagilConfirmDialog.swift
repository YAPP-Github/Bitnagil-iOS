//
//  BitnagilConfirmDialog.swift
//  Presentation
//
//  Created by 최정인 on 9/16/25.
//

import SnapKit
import UIKit

final class BitnagilConfirmDialog: UIViewController {
    private enum Layout {
        static let horizontalMargin: CGFloat = 24
        static let contentViewWidth: CGFloat = 277
        static let contentViewHeight: CGFloat = 152
        static let titleLabelTopSpacing: CGFloat = 20
        static let titleLabelHeight: CGFloat = 28
        static let messageLabelTopSpacing: CGFloat = 6
        static let messageLabelHeight: CGFloat = 40
        static let confirmButtonBottomSpacing: CGFloat = 20
    }

    private let dimmedView = UIView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let confirmButton = UIButton()
    private var confirmHandler: (() -> Void)?

    init(
        title: String,
        message: String,
        confirmHandler: (() -> Void)?
    ) {
        super.init(nibName: nil, bundle: nil)
        self.confirmHandler = confirmHandler
        titleLabel.text = title
        messageLabel.text = message

        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        view.backgroundColor = .clear
        dimmedView.backgroundColor = .black
        dimmedView.alpha = 0.7

        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true

        titleLabel.font = BitnagilFont(style: .subtitle1, weight: .semiBold).font
        titleLabel.textColor = BitnagilColor.gray10

        messageLabel.font = BitnagilFont(style: .body2, weight: .medium).font
        messageLabel.textColor = BitnagilColor.gray40
        messageLabel.numberOfLines = 2

        confirmButton.setTitle("확인", for: .normal)
        confirmButton.setTitleColor(BitnagilColor.orange500, for: .normal)
        confirmButton.titleLabel?.font = BitnagilFont(style: .body2, weight: .semiBold).font
        confirmButton.titleLabel?.textAlignment = .right

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
        contentView.addSubview(messageLabel)
        contentView.addSubview(confirmButton)

        dimmedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(Layout.contentViewWidth)
            make.height.equalTo(Layout.contentViewHeight)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Layout.titleLabelTopSpacing)
            make.horizontalEdges.equalToSuperview().inset(Layout.horizontalMargin)
            make.height.equalTo(Layout.titleLabelHeight)
        }

        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Layout.messageLabelTopSpacing)
            make.horizontalEdges.equalToSuperview().inset(Layout.horizontalMargin)
            make.height.equalTo(Layout.messageLabelHeight)
        }

        confirmButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(Layout.confirmButtonBottomSpacing)
            make.trailing.equalToSuperview().inset(Layout.horizontalMargin)
        }
    }
}
