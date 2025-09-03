//
//  TutorialTableCell.swift
//  Presentation
//
//  Created by 최정인 on 9/3/25.
//

import SnapKit
import UIKit

final class TutorialTableCell: UITableViewCell {
    private enum Layout {
        static let titleLableLeadingSpacing: CGFloat = 20
        static let chevronIconSize: CGFloat = 24
        static let chevronIconTrailingSpacing: CGFloat = 11
    }

    private let titleLabel = UILabel()
    private let chevronIcon = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String) {
        titleLabel.text = title
    }

    private func configureAttribute() {
        layer.masksToBounds = true
        layer.cornerRadius = 12
        backgroundColor = BitnagilColor.gray99

        titleLabel.font = BitnagilFont(style: .body2, weight: .medium).font
        titleLabel.textColor = BitnagilColor.gray10

        chevronIcon.image = BitnagilIcon.chevronRightIcon
        chevronIcon.contentMode = .scaleAspectFit
    }

    private func configureLayout() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(chevronIcon)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Layout.titleLableLeadingSpacing)
            make.centerY.equalToSuperview()
        }

        chevronIcon.snp.makeConstraints { make in
            make.size.equalTo(Layout.chevronIconSize)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(Layout.chevronIconTrailingSpacing)
        }
    }
}
