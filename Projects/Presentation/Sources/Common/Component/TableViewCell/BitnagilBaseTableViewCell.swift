//
//  MyPageTableViewCell.swift
//  Presentation
//
//  Created by 이동현 on 7/17/25.
//

import SnapKit
import UIKit

class BitnagilBaseTableViewCell: UITableViewCell {
    private enum Layout {
        static let titleLableLeadingSpacing: CGFloat = 20
    }

    private let titleLabel = UILabel()

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

    func configureAttribute() {
        titleLabel.font = BitnagilFont(style: .body1, weight: .regular).font
    }

    func configureLayout() {
        contentView.addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.leading.equalToSuperview().offset(Layout.titleLableLeadingSpacing)
        }
    }
}
