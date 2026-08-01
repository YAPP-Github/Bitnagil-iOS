//
//  YouthPolicyBadgeView.swift
//  Presentation
//

import SnapKit
import UIKit

final class YouthPolicyBadgeView: UIView {
    private enum Layout {
        static let badgeViewHeight: CGFloat = 26
        static let badgeLabelHeight: CGFloat = 18
        static let badgeLabelHorizontalSpacing: CGFloat = 10
        static let badgeLabelVerticalSpacing: CGFloat = 4
        static let cornerRadius: CGFloat = 6
    }

    private let badgeLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        layer.cornerRadius = Layout.cornerRadius
        layer.masksToBounds = true

        badgeLabel.font = BitnagilFont.init(style: .caption1, weight: .semiBold).font
    }

    private func configureLayout() {
        addSubview(badgeLabel)

        self.snp.makeConstraints { make in
            make.height.equalTo(Layout.badgeViewHeight)
        }

        badgeLabel.snp.makeConstraints { make in
            make.height.equalTo(Layout.badgeLabelHeight)

            make.verticalEdges
                .equalToSuperview()
                .inset(Layout.badgeLabelVerticalSpacing)

            make.horizontalEdges
                .equalToSuperview()
                .inset(Layout.badgeLabelHorizontalSpacing)
        }
    }

    func configure(with badge: YouthPolicyBadge) {
        backgroundColor = badge.backgroundColor

        badgeLabel.textColor = badge.titleColor
        badgeLabel.text = badge.description
    }
}
