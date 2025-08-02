//
//  SettingHeaderView.swift
//  Presentation
//
//  Created by 이동현 on 7/27/25.
//

import SnapKit
import UIKit

final class SettingHeaderView: UITableViewHeaderFooterView {
    private enum Layout {
        static let divideLineHeight: CGFloat = 6
        static let titleLabelTopSpacing: CGFloat = 18
        static let titleLabelHeight: CGFloat = 24
        static let titleLabelLeadingSpacing: CGFloat = 20
    }

    private let divideLine = UILabel()
    private let titleLabel = UILabel()
    private var titleLabelTopConstraint: Constraint?

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureAttribute() {
        divideLine.backgroundColor = BitnagilColor.gray99

        titleLabel.font = BitnagilFont.init(style: .caption1, weight: .semiBold).font
        titleLabel.textColor = BitnagilColor.gray60
    }

    private func configureLayout() {
        addSubview(divideLine)
        addSubview(titleLabel)

        divideLine.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(Layout.divideLineHeight)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Layout.titleLabelLeadingSpacing)
            make.height.equalTo(Layout.titleLabelHeight)
            titleLabelTopConstraint = make.top.equalToSuperview()
                .offset(Layout.titleLabelTopSpacing)
                .constraint
        }
    }

    func configure(shouldShowDivider: Bool, title: String) {
        let titleLabelTopSpacing: CGFloat = shouldShowDivider
            ? Layout.titleLabelTopSpacing
            : .zero

        divideLine.isHidden = !shouldShowDivider
        titleLabel.text = title
        titleLabelTopConstraint?.update(offset: titleLabelTopSpacing)
    }
}
