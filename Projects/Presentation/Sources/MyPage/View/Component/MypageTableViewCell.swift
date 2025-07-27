//
//  MyPageTableViewCell.swift
//  Presentation
//
//  Created by 이동현 on 7/17/25.
//

import SnapKit
import UIKit

final class MypageTableViewCell: UITableViewCell {
    private enum Layout {
        static let titleLableLeadingSpacing: CGFloat = 20
        static let titleLableTrailingSpacing: CGFloat = 8
        static let chevronImageViewTrailingSpacing: CGFloat = 16
        static let chevronImageViewSize: CGFloat = 16
    }

    private let titleLabel = UILabel()
    private let chevronImageView = UIImageView()

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
        titleLabel.font = BitnagilFont(style: .body1, weight: .regular).font

        chevronImageView.tintColor = .black
        chevronImageView.image = BitnagilIcon
            .chevronIcon(direction: .right)?
            .withRenderingMode(.alwaysTemplate)
    }

    private func configureLayout() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(chevronImageView)

        chevronImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(Layout.chevronImageViewTrailingSpacing)
            make.size.equalTo(Layout.chevronImageViewSize)
        }

        titleLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.leading.equalToSuperview().offset(Layout.titleLableLeadingSpacing)
            make.trailing.equalTo(chevronImageView.snp.leading).offset(-Layout.titleLableTrailingSpacing)
        }
    }
}
