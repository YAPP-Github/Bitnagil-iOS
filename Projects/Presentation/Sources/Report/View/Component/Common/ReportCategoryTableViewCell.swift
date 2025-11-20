//
//  ReportCategoryTableViewCell.swift
//  Presentation
//
//  Created by 이동현 on 11/15/25.
//

import Domain
import SnapKit
import UIKit

final class ReportCategoryTableViewCell: UITableViewCell {
    private enum Layout {
        static let iconImageViewSize: CGFloat = 24
        static let titleLabelTopSpacing: CGFloat = 14
        static let titleLabelLeadingSpacing: CGFloat = 14
        static let titleLabelHeight: CGFloat = 24
        static let contentLabelBottomSpacing: CGFloat = 14
        static let contentLabelHeight: CGFloat = 20
        static let checkIconHeight: CGFloat = 24
        static let checkIconWidth: CGFloat = 24
    }

    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let contentLabel = UILabel()
    private let checkIconImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        checkIconImageView.isHidden = true
    }

    private func configureAttribute() {
        titleLabel.textColor = BitnagilColor.gray10
        titleLabel.font = BitnagilFont.init(style: .body1, weight: .medium).font

        contentLabel.textColor = BitnagilColor.gray70
        contentLabel.font = BitnagilFont.init(style: .body2, weight: .medium).font

        checkIconImageView.image = BitnagilIcon.checkIcon?
            .withRenderingMode(.alwaysTemplate)
        checkIconImageView.tintColor = BitnagilColor.orange500
    }

    private func configureLayout() {
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(contentLabel)
        addSubview(checkIconImageView)

        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(Layout.iconImageViewSize)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading
                .equalTo(iconImageView.snp.trailing)
                .offset(Layout.titleLabelLeadingSpacing)

            make.top
                .equalToSuperview()
                .offset(Layout.titleLabelTopSpacing)

            make.height.equalTo(Layout.titleLabelHeight)
        }

        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.equalTo(titleLabel)
            make.height.equalTo(Layout.contentLabelHeight)
        }

        checkIconImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(Layout.checkIconWidth)
            make.height.equalTo(Layout.checkIconHeight)
        }
    }

    func configureCell(reportType: ReportType, isSelected: Bool) {
        iconImageView.image = reportType.iconImage
        titleLabel.text = reportType.name
        contentLabel.text = reportType.description

        checkIconImageView.isHidden = !isSelected
        selectionStyle = .none
    }
}

extension ReportType {
    var iconImage: UIImage? {
        switch self {
        case .transportation:
            BitnagilIcon.carIcon
        case .lamp:
            BitnagilIcon.lightIcon
        case .water:
            BitnagilIcon.waterIcon
        case .convenience:
            BitnagilIcon.hammerIcon
        }
    }
}
