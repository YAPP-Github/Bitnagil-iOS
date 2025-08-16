//
//  RoutineCardView.swift
//  Presentation
//
//  Created by 최정인 on 8/16/25.
//

import Domain
import SnapKit
import UIKit

final class RoutineCardView: UIView {
    private let headerInfoStackView = UIStackView()
    private let categoryIconView = RoutineCategoryIcon(routineCategory: .connection)
    private let titleLabel = UILabel()
    private let editButton = UIButton()
    private let deleteButton = UIButton()
    private let plusButton = UIButton()
    private let grayLine = UIView()
    private let subRoutineLabel = UILabel()
    private let subRoutineStackView = UIStackView()

    init() {
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        backgroundColor = .white
        layer.masksToBounds = true
        layer.cornerRadius = 12

        headerInfoStackView.axis = .horizontal
        headerInfoStackView.spacing = 10

        titleLabel.text = "개운하게 일어나기"
        titleLabel.font = BitnagilFont(style: .body1, weight: .semiBold).font
        titleLabel.textColor = BitnagilColor.gray10

        plusButton.setImage(BitnagilIcon.plusIcon, for: .normal)
        plusButton.tintColor = BitnagilColor.gray10

        grayLine.backgroundColor = BitnagilColor.gray97

        subRoutineStackView.axis = .vertical
        subRoutineStackView.spacing = 2

        subRoutineLabel.text = "세부 루틴"
        subRoutineLabel.font = BitnagilFont(style: .body2, weight: .medium).font
        subRoutineLabel.textColor = BitnagilColor.gray40
        subRoutineLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        subRoutineStackView.addArrangedSubview(subRoutineLabel)

        ["물 마시기", "물 마시기", "물 마시기"].forEach {
            let subRoutineTitleLabel = UILabel()
            subRoutineTitleLabel.text = "• \($0)"
            subRoutineTitleLabel.font = BitnagilFont(style: .body2, weight: .medium).font
            subRoutineTitleLabel.textColor = BitnagilColor.gray40
            subRoutineTitleLabel.snp.makeConstraints { make in
                make.height.equalTo(20)
            }
            subRoutineStackView.addArrangedSubview(subRoutineTitleLabel)
        }
    }

    private func configureLayout() {
        [categoryIconView, titleLabel].forEach {
            headerInfoStackView.addArrangedSubview($0)
        }
        addSubview(headerInfoStackView)
        addSubview(plusButton)
        addSubview(grayLine)
        addSubview(subRoutineStackView)

        categoryIconView.snp.makeConstraints { make in
            make.size.equalTo(32)
        }

        headerInfoStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview().offset(16)
        }

        plusButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().inset(7)
            make.size.equalTo(32)
        }

        grayLine.snp.makeConstraints { make in
            make.top.equalTo(headerInfoStackView.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(1)
        }

        subRoutineStackView.snp.makeConstraints { make in
            make.top.equalTo(grayLine.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(14)
        }
    }
}

private class RoutineCategoryIcon: UIView {
    private let routineCategoryIcon = UIImageView()
    private let routineCategory: RoutineCategoryType
    init(routineCategory: RoutineCategoryType) {
        self.routineCategory = routineCategory
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        layer.masksToBounds = true
        layer.cornerRadius = 3.76
        backgroundColor = routineCategory.iconBackgroundColor ?? BitnagilColor.yellow10
        routineCategoryIcon.image = routineCategory.iconImage ?? BitnagilIcon.shineIcon
    }

    private func configureLayout() {
        addSubview(routineCategoryIcon)
        routineCategoryIcon.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.center.equalToSuperview()
        }
    }
}
