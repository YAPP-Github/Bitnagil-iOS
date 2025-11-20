//
//  ReportHistoryEmptyView.swift
//  Presentation
//
//  Created by 이동현 on 11/20/25.
//

import SnapKit
import UIKit

final class ReportHistoryEmptyView: UIView {
    private enum Layout {
        static let semiBoldLabelHeight: CGFloat = 28
        static let regularLabelHeight: CGFloat = 20
        static let stackViewSpacing: CGFloat = 2
        static let stackViewHeight: CGFloat = 50
        static let stackViewWidth: CGFloat = 269
    }

    private let labelStackView = UIStackView()
    private let semiBoldLabel = UILabel()
    private let regularLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        backgroundColor = BitnagilColor.gray99

        labelStackView.axis = .vertical
        labelStackView.alignment = .center

        semiBoldLabel.font = BitnagilFont.init(style: .subtitle1, weight: .semiBold).font
        semiBoldLabel.textColor = BitnagilColor.gray30
        semiBoldLabel.text = "제보한 내역이 없어요."

        regularLabel.font = BitnagilFont.init(style: .body2, weight: .regular).font
        regularLabel.textColor = BitnagilColor.gray70
        regularLabel.text = "원하는 카테고리로 제보를 시작해보세요."
    }

    private func configureLayout() {
        addSubview(labelStackView)
        labelStackView.addArrangedSubview(semiBoldLabel)
        labelStackView.addArrangedSubview(regularLabel)

        labelStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(Layout.stackViewHeight)
            make.width.equalTo(Layout.stackViewWidth)
        }

        semiBoldLabel.snp.makeConstraints { make in
            make.height.equalTo(Layout.semiBoldLabelHeight)
        }

        regularLabel.snp.makeConstraints { make in
            make.height.equalTo(Layout.regularLabelHeight)
        }
    }
}
