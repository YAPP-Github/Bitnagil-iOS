//
//  BitnagilChevronTableViewCell.swift
//  Presentation
//
//  Created by 이동현 on 7/30/25.
//

import SnapKit
import UIKit

final class BitnagilChevronTableViewCell: BitnagilBaseTableViewCell {
    private enum Layout {
        static let chevronImageViewTrailingSpacing: CGFloat = 16
        static let chevronImageViewSize: CGFloat = 16
    }

    private let chevronImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configureAttribute() {
        super.configureAttribute()

        chevronImageView.tintColor = .black
        chevronImageView.image = BitnagilIcon
            .chevronIcon(direction: .right)?
            .withRenderingMode(.alwaysTemplate)
    }

    override func configureLayout() {
        super.configureLayout()

        contentView.addSubview(chevronImageView)

        chevronImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(Layout.chevronImageViewTrailingSpacing)
            make.size.equalTo(Layout.chevronImageViewSize)
        }
    }
}
