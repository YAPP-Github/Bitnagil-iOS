//
//  ReportHistoryTableHeaderView.swift
//  Presentation
//
//  Created by 이동현 on 11/15/25.
//

import SnapKit
import UIKit

final class ReportHistoryTableHeaderView: UITableViewHeaderFooterView {
    private enum Layout {
        static let labelHeight: CGFloat = 20
        static let weekLabelLeadingSpacing: CGFloat = 2
    }

    private let dateLabel = UILabel()
    private let weekLabel = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        backgroundColor = .clear

        dateLabel.textColor = BitnagilColor.gray10
        dateLabel.font = BitnagilFont.init(style: .body2, weight: .semiBold).font

        weekLabel.textColor = BitnagilColor.gray40
        weekLabel.font = BitnagilFont.init(style: .body2, weight: .medium).font
    }

    private func configureLayout() {
        contentView.addSubview(dateLabel)
        contentView.addSubview(weekLabel)

        dateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(Layout.labelHeight)
        }

        weekLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()

            make.leading
                .equalTo(dateLabel.snp.trailing)
                .offset(Layout.weekLabelLeadingSpacing)

            make.height.equalTo(Layout.labelHeight)
        }
    }

    func configure(with dateString: String) {
        guard let weekCharacter = dateString.last else {
            dateLabel.text = dateString
            weekLabel.text = nil
            return
        }
        
        let datePart = String(dateString.dropLast())
        dateLabel.text = datePart
        weekLabel.text = String(weekCharacter)
    }
}
