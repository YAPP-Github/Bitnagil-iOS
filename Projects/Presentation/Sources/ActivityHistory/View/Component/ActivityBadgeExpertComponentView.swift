//
//  ActivityBadgeExpertComponentView.swift
//  Presentation
//
//  Created by 최정인 on 7/1/26.
//

import SnapKit
import UIKit

final class ActivityBadgeExpertComponentView: UIView {
    private enum Layout {
        static let cornerRadius: CGFloat = 8
        static let stackViewSpacing: CGFloat = 6
        static let verticalInset: CGFloat = 8
        static let horizontalInset: CGFloat = 13
        static let iconSize: CGFloat = 15
    }

    private let stackView = UIStackView()
    private let iconView = UIImageView()
    private let expertLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        backgroundColor = BitnagilColor.orange700
        layer.masksToBounds = true
        layer.cornerRadius = Layout.cornerRadius

        stackView.axis = .horizontal
        stackView.spacing = Layout.stackViewSpacing

        iconView.image = BitnagilIcon.shineIcon

        expertLabel.font = BitnagilFont(style: .caption1, weight: .medium).font
        expertLabel.textColor = .white
    }

    private func configureLayout() {
        addSubview(stackView)
        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(expertLabel)

        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.edges.equalToSuperview().inset(
                UIEdgeInsets(
                    top: Layout.verticalInset,
                    left: Layout.horizontalInset,
                    bottom: Layout.verticalInset,
                    right: Layout.horizontalInset))
        }

        iconView.snp.makeConstraints { make in
            make.size.equalTo(Layout.iconSize)
        }
    }

    func configure(expertTitle: String) {
        expertLabel.text = expertTitle
        if expertTitle == "예비 전문가" {
            iconView.image = BitnagilIcon.shineIcon?.withRenderingMode(.alwaysTemplate)
            iconView.tintColor = .white
        } else {
            iconView.image = BitnagilIcon.shineIcon
            iconView.tintColor = nil
        }
    }
}
