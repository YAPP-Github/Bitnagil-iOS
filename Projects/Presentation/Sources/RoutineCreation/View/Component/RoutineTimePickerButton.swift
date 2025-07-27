//
//  RoutineTimePickerButton.swift
//  Presentation
//
//  Created by 이동현 on 7/27/25.
//

import SnapKit
import UIKit

final class RoutineTimePickerButton: UIButton {
    private enum Layout {
        static let chevronDownImageViewTrailingSpacing: CGFloat = 19
        static let chevronDownImageViewSize: CGFloat = 20
        static let labelLeadingSpacing: CGFloat = 24
    }

    private let chevronDownImageView = UIImageView()
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        layer.borderWidth = 1
        layer.borderColor = BitnagilColor.navy100?.cgColor
        layer.cornerRadius = 12
        backgroundColor = .white

        chevronDownImageView.contentMode = .scaleAspectFit
        chevronDownImageView.tintColor = BitnagilColor.navy400
        chevronDownImageView.image = BitnagilIcon
            .chevronIcon(direction: .down)?
            .withRenderingMode(.alwaysTemplate)

        label.text = "시간 선택"
        label.textColor = BitnagilColor.gray40
        label.font = BitnagilFont.init(style: .body2, weight: .medium).font
    }

    private func configureLayout() {
        addSubview(chevronDownImageView)
        addSubview(label)

        chevronDownImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Layout.chevronDownImageViewTrailingSpacing)
            make.centerY.equalToSuperview()
            make.size.equalTo(Layout.chevronDownImageViewSize)
        }

        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Layout.labelLeadingSpacing)
            make.centerY.equalToSuperview()
        }
    }

    func configure(title: String) {
        label.text = title
    }
}
