//
//  ToastView.swift
//  Presentation
//
//  Created by 최정인 on 9/2/25.
//

import SnapKit
import UIKit

final class ToastView: UIView {
    private enum Layout {
        static let horizontalMargin: CGFloat = 16
        static let checkIconSize: CGFloat = 24
        static let messageLabelLeadingSpacing: CGFloat = 8
    }

    private let checkIcon = UIImageView()
    private let messageLabel = UILabel()
    private let message: String

    init(message: String) {
        self.message = message
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureAttribute() {
        alpha = 0
        isHidden = true

        layer.masksToBounds = true
        layer.cornerRadius = 12
        backgroundColor = BitnagilColor.gray30

        checkIcon.image = BitnagilIcon.orangeCheckedCircleIcon

        messageLabel.text = message
        messageLabel.font = BitnagilFont(style: .body2, weight: .medium).font
        messageLabel.textColor = .white
    }

    private func configureLayout() {
        addSubview(checkIcon)
        addSubview(messageLabel)

        checkIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(Layout.horizontalMargin)
            make.size.equalTo(Layout.checkIconSize)
        }

        messageLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(checkIcon.snp.trailing).offset(Layout.messageLabelLeadingSpacing)
            make.trailing.equalToSuperview().offset(-Layout.horizontalMargin)
        }
    }

    func showToastMessageView() {
        alpha = 0
        isHidden = false

        UIView.animate(withDuration: 0.35, delay: 0.01) {
            self.alpha = 1
        } completion: { [weak self] _ in
            self?.hideToastMessageView()
        }
    }

    private func hideToastMessageView() {
        UIView.animate(withDuration: 0.35, delay: 2.0) {
            self.alpha = 0
        } completion: { _ in
            self.isHidden = true
        }
    }
}
