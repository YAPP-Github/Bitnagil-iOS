//
//  ReportHistoryCategoryCollectionViewCell.swift
//  Presentation
//
//  Created by 이동현 on 11/15/25.
//

import Domain
import SnapKit
import UIKit

final class ReportHistoryCategoryCollectionViewCell: UICollectionViewCell {
    private enum Layout {
        static let labelHorizontalSpacing: CGFloat = 14
        static let labelVerticalSpacing: CGFloat = 9
        static let cornerRadius: CGFloat = 18
    }

    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        titleLabel.font = BitnagilFont.init(
            style: .caption1,
            weight: .semiBold
        ).font

        contentView.layer.cornerRadius = Layout.cornerRadius
        contentView.layer.masksToBounds = true
    }

    private func configureLayout() {
        contentView.addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges
                .equalToSuperview()
                .inset(Layout.labelHorizontalSpacing)

            make.verticalEdges
                .equalToSuperview()
                .inset(Layout.labelVerticalSpacing)
        }
    }

    func configure(
        progress: ReportProgress,
        count: Int?,
        isSelected: Bool
    ) {
        let countText: String

        if let count {
            countText = " \(count)"
        } else {
            countText = ""
        }

        titleLabel.text = "\(progress.description)\(countText)"

        contentView.backgroundColor = isSelected ? BitnagilColor.gray10 : .white
        titleLabel.textColor = isSelected ? .white : BitnagilColor.gray60
    }
}
