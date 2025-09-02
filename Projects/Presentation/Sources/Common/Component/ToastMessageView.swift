//
//  ToastMessageView.swift
//  Presentation
//
//  Created by 이동현 on 8/7/25.
//

import SnapKit
import UIKit

public final class ToastMessageView: UIView {
    private enum Layout {
        static let checkImageViewSize: CGFloat = 24
        static let checkImageViewLeadingSpace: CGFloat = 16
        static let checkImageViewTrailingSpace: CGFloat = 4
        static let labelHorizontalSpace: CGFloat = 20
        static let verticalSpace: CGFloat = 10
        static let height: CGFloat = 44
        static let width: CGFloat = 200
    }

    private let checkImageView = UIImageView()
    private let label = UILabel()
    private var labelLeadingConstraint: Constraint?
    private var heightConstraint: Constraint?
    private var widthConstraint: Constraint?

    init() {
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        self.alpha = 0
        self.isHidden = true

        backgroundColor = BitnagilColor.gray30
        layer.cornerRadius = 8
        layer.masksToBounds = true

        checkImageView.image = BitnagilIcon.checkIcon?.withRenderingMode(.alwaysTemplate)
        checkImageView.tintColor = BitnagilColor.orange500

        label.font = BitnagilFont.init(style: .body2, weight: .medium).font
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
    }

    private func configureLayout() {
        addSubview(checkImageView)
        addSubview(label)

        checkImageView.snp.makeConstraints { make in
            make.size.equalTo(Layout.checkImageViewSize)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(Layout.checkImageViewLeadingSpace)
        }

        label.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-Layout.labelHorizontalSpace)
            make.verticalEdges.equalToSuperview().inset(Layout.verticalSpace)
            labelLeadingConstraint = make
                .leading
                .equalToSuperview()
                .offset(Layout.labelHorizontalSpace)
                .constraint
        }

        snp.makeConstraints { make in
            heightConstraint = make
                .height
                .equalTo(Layout.height)
                .constraint
            widthConstraint = make
                .width
                .equalTo(Layout.width)
                .constraint
        }
    }

    func showToast(
        withCheckImage: Bool,
        message: String,
        width: CGFloat,
        height: CGFloat
    ) {
        guard isHidden else { return }

        label.text = message
        checkImageView.isHidden = !withCheckImage

        let labelLeadingSpacing = withCheckImage
            ? Layout.checkImageViewLeadingSpace + Layout.checkImageViewSize + Layout.checkImageViewTrailingSpace
            : Layout.labelHorizontalSpace

        labelLeadingConstraint?.update(offset: labelLeadingSpacing)
        heightConstraint?.update(offset: height)
        widthConstraint?.update(offset: width + 10)

        self.alpha = 0
        self.isHidden = false

        UIView.animate(withDuration: 0.35, delay: 0.01) {
            self.alpha = 1
        } completion: { [weak self] _ in
            self?.hideToast()
        }
    }

    private func hideToast() {
        UIView.animate(withDuration: 0.35, delay: 3.2) {
            self.alpha = 0
        } completion: { _ in
            self.isHidden = true
        }
    }
}
