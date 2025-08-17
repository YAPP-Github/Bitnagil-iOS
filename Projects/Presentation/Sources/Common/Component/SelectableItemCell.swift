//
//  SelectableItemCell.swift
//  Presentation
//
//  Created by 최정인 on 7/24/25.
//

import SnapKit
import UIKit

final class SelectableItemCell: UITableViewCell {
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
        titleLabel.font = BitnagilFont(style: .body1, weight: .regular).font
        titleLabel.textColor = BitnagilColor.gray10

        let checkImage = BitnagilIcon.checkIcon?
            .resizeAspectFit(to: CGSize(width: Layout.checkIconSize, height: Layout.checkIconSize))?
            .withRenderingMode(.alwaysTemplate)
        checkIcon.tintColor = BitnagilColor.orange500
        checkIcon.image = checkImage
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

    func configureCell(item: SelectableItem, isSelected: Bool) {
        checkIcon.isHidden = !isSelected

        guard let displayName = item.displayName else {
            titleLabel.text = item.description
            return
        }
        let attributedString = NSMutableAttributedString(string: item.description)
        attributedString.addAttribute(
            .font,
            value: BitnagilFont(style: .body1, weight: .regular).font,
            range: NSRange(location: 0, length: item.description.count))

        if let range = item.description.range(of: displayName) {
            let nsRange = NSRange(range, in: item.description)
            attributedString.addAttributes([
                .font: BitnagilFont(style: .body1, weight: .semiBold).font
            ], range: nsRange)
        }
        titleLabel.attributedText = attributedString
    }
}
