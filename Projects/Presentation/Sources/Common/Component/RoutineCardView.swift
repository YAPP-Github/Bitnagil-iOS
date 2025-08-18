//
//  RoutineCardView.swift
//  Presentation
//
//  Created by 최정인 on 8/16/25.
//

import Domain
import SnapKit
import UIKit

protocol RoutineCardViewDelegate: AnyObject {
    func routineCardView(_ sender: RoutineCardView, didTapPlusButton routine: RecommendedRoutine)
}

final class RoutineCardView: UIView {
    private enum Layout {
        static let horizontalMargin: CGFloat = 16
        static let cornerRadius: CGFloat = 12
        static let headerInfoStackViewSpacing: CGFloat = 10
        static let headerInfoStackViewTopSpacing: CGFloat = 14
        static let subRoutineStackViewSpacing: CGFloat = 2
        static let subRoutineStackViewTopSpacing: CGFloat = 10
        static let subRoutineStackViewBottomSpacing: CGFloat = 14
        static let subRoutineLabelHeight: CGFloat = 20
        static let categoryIconSize: CGFloat = 32
        static let plusImageSize: CGFloat = 24
        static let plusButtonTopSpacing: CGFloat = 14
        static let plusButtonTrailingSpacing: CGFloat = 7
        static let plusButtonSize: CGFloat = 32
        static let grayLineTopSpacing: CGFloat = 10
        static let grayLineHeight: CGFloat = 1
    }

    private let headerInfoStackView = UIStackView()
    private lazy var categoryIconView = RoutineCategoryIcon(routineCategory: routine.routineType)
    private let titleLabel = UILabel()
    private let editButton = UIButton()
    private let deleteButton = UIButton()
    private let plusButton = UIButton()
    private let grayLine = UIView()
    private let subRoutineLabel = UILabel()
    private let subRoutineStackView = UIStackView()

    private let routine: RecommendedRoutine
    weak var delegate: RoutineCardViewDelegate?
    init(routine: RecommendedRoutine) {
        self.routine = routine
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
        layer.cornerRadius = Layout.cornerRadius

        headerInfoStackView.axis = .horizontal
        headerInfoStackView.spacing = Layout.headerInfoStackViewSpacing

        titleLabel.text = routine.mainTitle
        titleLabel.font = BitnagilFont(style: .body1, weight: .semiBold).font
        titleLabel.textColor = BitnagilColor.gray10

        let plusImage = BitnagilIcon.plusIcon?
            .resizeAspectFit(to: CGSize(width: Layout.plusImageSize, height: Layout.plusImageSize))
        plusButton.setImage(plusImage, for: .normal)
        plusButton.tintColor = BitnagilColor.gray10
        plusButton.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                delegate?.routineCardView(self, didTapPlusButton: routine)
            }, for: .touchUpInside)

        grayLine.backgroundColor = BitnagilColor.gray97

        subRoutineStackView.axis = .vertical
        subRoutineStackView.spacing = Layout.subRoutineStackViewSpacing

        subRoutineLabel.text = "세부 루틴"
        subRoutineLabel.font = BitnagilFont(style: .body2, weight: .medium).font
        subRoutineLabel.textColor = BitnagilColor.gray40
        subRoutineLabel.snp.makeConstraints { make in
            make.height.equalTo(Layout.subRoutineLabelHeight)
        }
        subRoutineStackView.addArrangedSubview(subRoutineLabel)

        routine.subRoutines.forEach {
            let subRoutineTitleLabel = UILabel()
            subRoutineTitleLabel.text = "• \($0)"
            subRoutineTitleLabel.font = BitnagilFont(style: .body2, weight: .medium).font
            subRoutineTitleLabel.textColor = BitnagilColor.gray40
            subRoutineTitleLabel.snp.makeConstraints { make in
                make.height.equalTo(Layout.subRoutineLabelHeight)
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
            make.size.equalTo(Layout.categoryIconSize)
        }

        headerInfoStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Layout.headerInfoStackViewTopSpacing)
            make.leading.equalToSuperview().offset(Layout.horizontalMargin)
        }

        plusButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Layout.plusButtonTopSpacing)
            make.trailing.equalToSuperview().inset(Layout.plusButtonTrailingSpacing)
            make.size.equalTo(Layout.plusButtonSize)
        }

        grayLine.snp.makeConstraints { make in
            make.top.equalTo(headerInfoStackView.snp.bottom).offset(Layout.grayLineTopSpacing)
            make.leading.equalToSuperview().offset(Layout.horizontalMargin)
            make.trailing.equalToSuperview().inset(Layout.horizontalMargin)
            make.height.equalTo(Layout.grayLineHeight)
        }

        subRoutineStackView.snp.makeConstraints { make in
            make.top.equalTo(grayLine.snp.bottom).offset(Layout.subRoutineStackViewTopSpacing)
            make.leading.equalToSuperview().offset(Layout.horizontalMargin)
            make.trailing.equalToSuperview().inset(Layout.horizontalMargin)
            make.bottom.equalToSuperview().inset(Layout.subRoutineStackViewBottomSpacing)
        }
    }
}

fileprivate class RoutineCategoryIcon: UIView {
    private enum Layout {
        static let cornerRadius: CGFloat = 3.76
        static let iconSize: CGFloat = 24
    }

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
        layer.cornerRadius = Layout.cornerRadius
        backgroundColor = routineCategory.iconBackgroundColor ?? BitnagilColor.yellow10
        routineCategoryIcon.image = routineCategory.iconImage ?? BitnagilIcon.shineIcon
    }

    private func configureLayout() {
        addSubview(routineCategoryIcon)
        routineCategoryIcon.snp.makeConstraints { make in
            make.size.equalTo(Layout.iconSize)
            make.center.equalToSuperview()
        }
    }
}
