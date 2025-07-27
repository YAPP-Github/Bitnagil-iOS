//
//  DetailRoutineAdditionButton.swift
//  Presentation
//
//  Created by 이동현 on 7/21/25.
//

import SnapKit
import UIKit

final class SubroutineAdditionButton: UIButton {
    private enum Layout {
        static let plusImageViewLeadingSpacing: CGFloat = 24
        static let plusImageViewSize: CGFloat = 20
        static let labelLeadingSpacing: CGFloat = 10
    }

    private let plusImageView = UIImageView()
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

        plusImageView.contentMode = .scaleAspectFit
        plusImageView.tintColor = BitnagilColor.navy400
        plusImageView.image = BitnagilIcon
            .routineCreationIcon?
            .withRenderingMode(.alwaysTemplate)

        label.text = "세부루틴 추가"
        label.textColor = BitnagilColor.gray40
        label.font = BitnagilFont.init(style: .body2, weight: .medium).font
    }

    private func configureLayout() {
        addSubview(plusImageView)
        addSubview(label)

        plusImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Layout.plusImageViewLeadingSpacing)
            make.centerY.equalToSuperview()
            make.size.equalTo(Layout.plusImageViewSize)
        }

        label.snp.makeConstraints { make in
            make.leading.equalTo(plusImageView.snp.trailing).offset(Layout.labelLeadingSpacing)
            make.centerY.equalToSuperview()
        }
    }
}
