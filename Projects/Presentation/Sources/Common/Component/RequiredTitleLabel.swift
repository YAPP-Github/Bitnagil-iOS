//
//  RequiredTitleLabel.swift
//  Presentation
//
//  Created by 이동현 on 11/8/25.
//

import SnapKit
import UIKit

final class RequiredTitleLabel: UIView {
    private enum Layout {
        static let asteriskLeadingSpacing: CGFloat = 3
    }

    private let titleLabel = UILabel()
    private let asteriskLabel = UILabel()

    init(title: String) {
        super.init(frame: .zero)
        configureAttribute(title: title)
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute(title: String) {
        titleLabel.font = BitnagilFont.init(
            style: .body2,
            weight: .semiBold
        ).font
        titleLabel.textColor = BitnagilColor.gray10
        titleLabel.text = title

        asteriskLabel.text = "*"
        asteriskLabel.font = BitnagilFont.init(
            style: .body1,
            weight: .semiBold
        ).font
        asteriskLabel.textColor = BitnagilColor.error
    }

    private func configureLayout() {
        addSubview(titleLabel)
        addSubview(asteriskLabel)

        titleLabel.snp.makeConstraints { make in
            make.verticalEdges.leading.equalToSuperview()
        }

        asteriskLabel.snp.makeConstraints { make in
            make.leading
                .equalTo(titleLabel.snp.trailing)
                .offset(Layout.asteriskLeadingSpacing)

            make.top.equalTo(titleLabel)
        }
    }
}
