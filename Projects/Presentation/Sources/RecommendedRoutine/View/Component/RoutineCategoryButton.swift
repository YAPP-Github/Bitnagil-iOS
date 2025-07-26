//
//  RoutineCategoryView.swift
//  Presentation
//
//  Created by 최정인 on 7/12/25.
//

import SnapKit
import UIKit

final class RoutineCategoryButton: UIButton {

    private let buttonHeight: CGFloat = 36
    private let routineCategory: RoutineCategoryType
    private let categoryLabel = UILabel()

    private var isChecked: Bool = false {
        didSet {
            updateButtonAttribute()
        }
    }

    init(category: RoutineCategoryType) {
        self.routineCategory = category
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        backgroundColor = BitnagilColor.gray99

        categoryLabel.text = routineCategory.title
        categoryLabel.font = BitnagilFont(style: .caption1, weight: .regular).font
        categoryLabel.textColor = BitnagilColor.navy100
    }

    private func configureLayout() {
        layer.cornerRadius = buttonHeight / 2
        layer.masksToBounds = true

        addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func updateButtonAttribute() {
        let semiBoldFont = BitnagilFont(style: .caption1, weight: .semiBold).font
        let regularFont = BitnagilFont(style: .caption1, weight: .regular).font

        backgroundColor = isChecked ? BitnagilColor.navy500 : BitnagilColor.gray99
        categoryLabel.font = isChecked ? semiBoldFont : regularFont
        categoryLabel.textColor = isChecked ? .white : BitnagilColor.navy100
    }

    func updateButtonState(isChecked: Bool) {
        self.isChecked = isChecked
    }
}
