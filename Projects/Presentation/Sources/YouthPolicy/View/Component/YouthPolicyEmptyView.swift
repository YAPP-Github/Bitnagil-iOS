//
//  YouthPolicyEmptyView.swift
//  Presentation
//

import SnapKit
import UIKit

final class YouthPolicyEmptyView: UIView {
    private enum Layout {
        static let semiBoldLabelHeight: CGFloat = 28
        static let regularLabelHeight: CGFloat = 20
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

        regularLabel.font = BitnagilFont.init(style: .body2, weight: .regular).font
        regularLabel.textColor = BitnagilColor.gray70
    }

    private func configureLayout() {
        addSubview(labelStackView)
        labelStackView.addArrangedSubview(semiBoldLabel)
        labelStackView.addArrangedSubview(regularLabel)

        labelStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(Layout.stackViewHeight).priority(.medium)
            make.width.equalTo(Layout.stackViewWidth)
        }

        semiBoldLabel.snp.makeConstraints { make in
            make.height.equalTo(Layout.semiBoldLabelHeight)
        }

        regularLabel.snp.makeConstraints { make in
            make.height.equalTo(Layout.regularLabelHeight)
        }
    }

    func configure(with tab: YouthPolicyTab) {
        switch tab {
        case .entire:
            semiBoldLabel.text = "아직 공고가 없어요."
            regularLabel.text = "곧 새로운 소식을 가져올게요!"
        case .bookmarked:
            semiBoldLabel.text = "찜한 공고가 없어요."
            regularLabel.text = "관심있는 공고를 찜해보세요!"
        }
    }
}
