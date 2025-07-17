//
//  RoutineLevelCell.swift
//  Presentation
//
//  Created by 최정인 on 7/17/25.
//

import UIKit

final class RoutineLevelCell: UITableViewCell {

    private enum Layout {
        static let checkIconSize: CGFloat = 16
        static let horizontalMargin: CGFloat = 20
    }

    private let titleLabel = UILabel()
    private let checkIcon = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        titleLabel.do {
            $0.font = BitnagilFont(style: .body1, weight: .regular).font
            $0.textColor = .black
        }

        checkIcon.do {
            let checkImage = BitnagilIcon.checkIcon?
                .resizeAspectFit(to: CGSize(width: Layout.checkIconSize, height: Layout.checkIconSize))?
                .withRenderingMode(.alwaysTemplate)
            $0.tintColor = BitnagilColor.orange500
            $0.image = checkImage
        }
    }

    private func configureLayout() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(checkIcon)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Layout.horizontalMargin)
            make.centerY.equalToSuperview()
        }

        checkIcon.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Layout.horizontalMargin)
            make.centerY.equalToSuperview()
            make.size.equalTo(Layout.checkIconSize)
        }
    }

    func configureCell(level: RoutineLevelType, isSelected: Bool) {
        titleLabel.text = level.levelTitle
        checkIcon.isHidden = !isSelected
    }
}
