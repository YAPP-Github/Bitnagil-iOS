//
//  ReportHistoryTableViewCell.swift
//  Presentation
//
//  Created by 이동현 on 11/15/25.
//

import Domain
import SnapKit
import UIKit

final class ReportHistoryTableViewCell: UITableViewCell {
    private enum Layout {
        static let horizontalSpacing: CGFloat = 16
        static let verticalSpacing: CGFloat = 14
        static let containerViewBottomSpacing: CGFloat = 10
        static let photoSize: CGFloat = 74
        static let progressViewHeight: CGFloat = 26
        static let progressLabelHeight: CGFloat = 18
        static let progressLabelHorizontalSpacing: CGFloat = 10
        static let progressLabelVerticalSpacing: CGFloat = 4
        static let titleLabelMaxHeight: CGFloat = 40
        static let titleLabelTopSpacing: CGFloat = 8
        static let titleLabelTrailingSpacing: CGFloat = 14
        static let categoryLabelWidth: CGFloat = 48
        static let categoryLabelTopSpacing: CGFloat = 12
        static let dotViewHorizontalSpacing: CGFloat = 6
        static let dotViewSize: CGFloat = 4
        static let containerViewCornerRadius: CGFloat = 12
    }

    private let containerView = UIView()
    private let progressView = UIView()
    private let progressLabel = UILabel()
    private let titleLabel = UILabel()
    private let categoryLabel = UILabel()
    private let dotView = UIView()
    private let addressLabel = UILabel()
    private let photoImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configureLayout()
        configureAttribute()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func configureAttribute() {
        backgroundColor = .clear
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = Layout.containerViewCornerRadius
        containerView.layer.masksToBounds = true

        progressView.layer.cornerRadius = 6
        progressView.layer.masksToBounds = true

        photoImageView.layer.cornerRadius = 9.25
        photoImageView.layer.masksToBounds = true

        titleLabel.textColor = BitnagilColor.gray10
        titleLabel.font = BitnagilFont.init(style: .body2, weight: .semiBold).font
        titleLabel.textAlignment = .left

        categoryLabel.textColor = BitnagilColor.gray50
        categoryLabel.font = BitnagilFont.init(style: .caption1, weight: .semiBold).font

        addressLabel.textColor = BitnagilColor.gray50
        addressLabel.font = BitnagilFont.init(style: .caption1, weight: .medium).font

        dotView.backgroundColor = BitnagilColor.gray90
        dotView.layer.cornerRadius = Layout.dotViewSize / 2
        dotView.layer.masksToBounds = true
    }

    private func configureLayout() {
        addSubview(containerView)
        containerView.addSubview(progressView)
        containerView.addSubview(progressLabel)
        containerView.addSubview(photoImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(categoryLabel)
        containerView.addSubview(dotView)
        containerView.addSubview(addressLabel)

        containerView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()

            make.bottom
                .equalToSuperview()
                .offset(-Layout.containerViewBottomSpacing)
        }

        progressView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Layout.horizontalSpacing)
            make.top.equalToSuperview().offset(Layout.verticalSpacing)
            make.height.equalTo(Layout.progressViewHeight)
        }

        progressLabel.snp.makeConstraints { make in
            make.height.equalTo(Layout.progressLabelHeight)

            make.verticalEdges
                .equalTo(progressView)
                .inset(Layout.progressLabelVerticalSpacing)

            make.horizontalEdges
                .equalTo(progressView)
                .inset(Layout.progressLabelHorizontalSpacing)
        }

        photoImageView.snp.makeConstraints { make in
            make.verticalEdges
                .equalToSuperview()
                .inset(Layout.verticalSpacing)

            make.trailing
                .equalToSuperview()
                .offset(-Layout.horizontalSpacing)

            make.size.equalTo(Layout.photoSize)
        }

        titleLabel.snp.makeConstraints { make in
            make.top
                .equalTo(progressView.snp.bottom)
                .offset(Layout.titleLabelTopSpacing)

            make.leading
                .equalToSuperview()
                .offset(Layout.horizontalSpacing)

            make.trailing
                .equalTo(photoImageView.snp.leading)
                .offset(-Layout.titleLabelTrailingSpacing)
        }

        categoryLabel.snp.makeConstraints { make in
            make.leading
                .equalToSuperview()
                .offset(Layout.horizontalSpacing)

            make.top
                .equalTo(titleLabel.snp.bottom)
                .offset(Layout.categoryLabelTopSpacing)

            make.bottom
                .equalToSuperview()
                .offset(-Layout.verticalSpacing)

            make.width
                .equalTo(Layout.categoryLabelWidth)
                .priority(.medium)
        }

        dotView.snp.makeConstraints { make in
            make.size.equalTo(Layout.dotViewSize)

            make.centerY.equalTo(categoryLabel)

            make.leading
                .equalTo(categoryLabel.snp.trailing)
                .offset(Layout.dotViewHorizontalSpacing)
        }

        addressLabel.snp.makeConstraints { make in
            make.centerY.equalTo(categoryLabel)

            make.leading
                .equalTo(dotView.snp.trailing)
                .offset(Layout.dotViewHorizontalSpacing)

            make.trailing
                .equalTo(titleLabel.snp.trailing)
        }
    }

    func configure(with item: ReportHistoryItem) {
        progressView.backgroundColor = item.progress.backgroundColor

        progressLabel.textColor = item.progress.titleColor
        progressLabel.text = item.progress.description
        progressLabel.font = BitnagilFont.init(style: .caption1, weight: .semiBold).font

        titleLabel.text = item.title

        categoryLabel.text = item.type.name


        addressLabel.text = item.location

        guard let imageURL = URL(string: item.thumbnailUrl) else {
            return
        }

        photoImageView.kf.setImage(with: imageURL)
    }
}

extension ReportProgress {
    var backgroundColor: UIColor? {
        switch self {
        case .received:
            BitnagilColor.green10
        case .inProgress:
            BitnagilColor.skyblue10
        case .completed:
            BitnagilColor.gray95
        case .entire:
            nil
        }
    }

    var titleColor: UIColor? {
        switch self {
        case .received:
            BitnagilColor.green500
        case .inProgress:
            BitnagilColor.lightBlue300
        case .completed:
            BitnagilColor.gray40
        case .entire:
            nil
        }
    }
}
