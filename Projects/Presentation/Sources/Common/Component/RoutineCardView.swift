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
    func routineCardView(_ sender: RoutineCardView, didTapEditButton routine: Routine)
    func routineCardView(_ sender: RoutineCardView, didTapDeleteButton routine: Routine)
}

final class RoutineCardView: UIView {
    private enum Layout {
        static let horizontalMargin: CGFloat = 16
        static let cornerRadius: CGFloat = 12
        static let headerInfoStackViewSpacing: CGFloat = 10
        static let headerInfoStackViewTopSpacing: CGFloat = 14
        static let routineInfoStackViewVerticalMargin: CGFloat = 14
        static let routineInfoStackViewSpacing: CGFloat = 10
        static let stackViewSpacing: CGFloat = 2
        static let subLabelHeight: CGFloat = 20
        static let categoryIconSize: CGFloat = 32
        static let plusImageSize: CGFloat = 24
        static let plusButtonTopSpacing: CGFloat = 14
        static let buttonTrailingSpacing: CGFloat = 7
        static let editButtonTrailingSpacing: CGFloat = 40
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
    private let routineInfoStackView = UIStackView()
    private let grayLine = UIView()
    private let subRoutineLabel = UILabel()
    private let subRoutineStackView = UIStackView()
    private let grayLine2 = UIView()
    private let infoStackView = UIStackView()

    private let routine: RoutineProtocol
    weak var delegate: RoutineCardViewDelegate?
    init(routine: RoutineProtocol) {
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

        titleLabel.text = routine.title
        titleLabel.font = BitnagilFont(style: .body1, weight: .semiBold).font
        titleLabel.textColor = BitnagilColor.gray10

        editButton.setImage(BitnagilIcon.editIcon, for: .normal)
        editButton.addAction(
            UIAction { [weak self] _ in
                guard
                    let self,
                    let routine = self.routine as? Routine
                else { return }
                self.delegate?.routineCardView(self, didTapEditButton: routine)
            },
            for: .touchUpInside)

        deleteButton.setImage(BitnagilIcon.trashIcon, for: .normal)
        deleteButton.addAction(
            UIAction { [weak self] _ in
                guard
                    let self,
                    let routine = self.routine as? Routine
                else { return }
                self.delegate?.routineCardView(self, didTapDeleteButton: routine)
            },
            for: .touchUpInside)

        let plusImage = BitnagilIcon.plusIcon?
            .resizeAspectFit(to: CGSize(width: Layout.plusImageSize, height: Layout.plusImageSize))
        plusButton.setImage(plusImage, for: .normal)
        plusButton.tintColor = BitnagilColor.gray10
        plusButton.addAction(
            UIAction { [weak self] _ in
                guard
                    let self,
                    let routine = self.routine as? RecommendedRoutine
                else { return }
                self.delegate?.routineCardView(self, didTapPlusButton: routine)
            },
            for: .touchUpInside)

        routineInfoStackView.axis = .vertical
        routineInfoStackView.spacing = Layout.routineInfoStackViewSpacing

        grayLine.backgroundColor = BitnagilColor.gray97
        grayLine2.backgroundColor = BitnagilColor.gray97

        subRoutineStackView.axis = .vertical
        subRoutineStackView.spacing = Layout.stackViewSpacing

        if !routine.subRoutines.isEmpty {
            subRoutineLabel.text = "세부 루틴"
            subRoutineLabel.font = BitnagilFont(style: .body2, weight: .medium).font
            subRoutineLabel.textColor = BitnagilColor.gray40
            subRoutineStackView.addArrangedSubview(subRoutineLabel)
            subRoutineLabel.snp.makeConstraints { make in
                make.height.equalTo(Layout.subLabelHeight)
            }

            routine.subRoutines.forEach {
                let subRoutineTitleLabel = UILabel()
                subRoutineTitleLabel.text = "• \($0)"
                subRoutineTitleLabel.font = BitnagilFont(style: .body2, weight: .medium).font
                subRoutineTitleLabel.textColor = BitnagilColor.gray40
                subRoutineStackView.addArrangedSubview(subRoutineTitleLabel)
                subRoutineTitleLabel.snp.makeConstraints { make in
                    make.height.equalTo(Layout.subLabelHeight)
                }
            }
        } else {
            grayLine.isHidden = true
            subRoutineStackView.isHidden = true
        }

        if let mainRoutine = routine as? Routine {
            infoStackView.axis = .vertical
            infoStackView.spacing = Layout.stackViewSpacing

            plusButton.isHidden = true

            // 반복 주기
            let repeatDayText = mainRoutine.repeatDay.isEmpty ? "X" : mainRoutine.repeatDay.map({ $0.koreanValue }).joined(separator: ", ")
            let repeatDayLabel = UILabel()
            repeatDayLabel.text = "반복: \(repeatDayText)"
            repeatDayLabel.font = BitnagilFont(style: .body2, weight: .medium).font
            repeatDayLabel.textColor = BitnagilColor.gray40
            infoStackView.addArrangedSubview(repeatDayLabel)
            repeatDayLabel.snp.makeConstraints { make in
                make.height.equalTo(Layout.subLabelHeight)
            }

            // 기간
            let periodLabel = UILabel()
            let startDate = mainRoutine.startDate.convertToString(dateType: .yearMonthDateShort)
            let endDate = mainRoutine.endDate.convertToString(dateType: .yearMonthDateShort)
            let periodText = startDate == endDate ? "X" : "\(startDate) - \(endDate)"
            periodLabel.text = "기간: \(periodText)"
            periodLabel.font = BitnagilFont(style: .body2, weight: .medium).font
            periodLabel.textColor = BitnagilColor.gray40
            infoStackView.addArrangedSubview(periodLabel)
            periodLabel.snp.makeConstraints { make in
                make.height.equalTo(Layout.subLabelHeight)
            }

            // 시간
            let timeLabel = UILabel()
            let textTime = mainRoutine.startTime.convertToString(dateType: .time24hour) == "00:00" ? "하루종일" : mainRoutine.startTime.convertToString(dateType: .amPmTime)
            timeLabel.text = "시간: \(textTime)"
            timeLabel.font = BitnagilFont(style: .body2, weight: .medium).font
            timeLabel.textColor = BitnagilColor.gray40
            infoStackView.addArrangedSubview(timeLabel)
            timeLabel.snp.makeConstraints { make in
                make.height.equalTo(Layout.subLabelHeight)
            }
        } else {
            grayLine2.isHidden = true
            infoStackView.isHidden = true
        }
    }

    private func configureLayout() {
        [categoryIconView, titleLabel].forEach {
            headerInfoStackView.addArrangedSubview($0)
        }
        addSubview(headerInfoStackView)
        addSubview(plusButton)
        [grayLine, subRoutineStackView, grayLine2, infoStackView].forEach {
            routineInfoStackView.addArrangedSubview($0)
        }
        addSubview(routineInfoStackView)

        categoryIconView.snp.makeConstraints { make in
            make.size.equalTo(Layout.categoryIconSize)
        }

        headerInfoStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Layout.headerInfoStackViewTopSpacing)
            make.leading.equalToSuperview().offset(Layout.horizontalMargin)
        }

        plusButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Layout.plusButtonTopSpacing)
            make.trailing.equalToSuperview().offset(-Layout.buttonTrailingSpacing)
            make.size.equalTo(Layout.plusButtonSize)
        }

        [grayLine, grayLine2].forEach { view in
            view.snp.makeConstraints { make in
                make.horizontalEdges.equalToSuperview()
                make.height.equalTo(Layout.grayLineHeight)
            }
        }

        [subRoutineStackView, infoStackView].forEach { view in
            view.snp.makeConstraints { make in
                make.horizontalEdges.equalToSuperview()
            }
        }

        routineInfoStackView.snp.makeConstraints { make in
            make.top.equalTo(headerInfoStackView.snp.bottom).offset(Layout.routineInfoStackViewVerticalMargin)
            make.leading.equalToSuperview().offset(Layout.horizontalMargin)
            make.trailing.equalToSuperview().inset(Layout.horizontalMargin)
            make.bottom.equalToSuperview().inset(Layout.routineInfoStackViewVerticalMargin)
        }

        if let _ = routine as? Routine {
            addSubview(editButton)
            addSubview(deleteButton)

            editButton.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(Layout.plusButtonTopSpacing)
                make.trailing.equalTo(deleteButton).offset(-Layout.editButtonTrailingSpacing)
                make.size.equalTo(Layout.plusButtonSize)
            }

            deleteButton.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(Layout.plusButtonTopSpacing)
                make.trailing.equalToSuperview().inset(Layout.buttonTrailingSpacing)
                make.size.equalTo(Layout.plusButtonSize)
            }
        }
    }
}

fileprivate class RoutineCategoryIcon: UIView {
    private enum Layout {
        static let cornerRadius: CGFloat = 3.76
        static let iconSize: CGFloat = 24
    }

    private let routineCategoryIcon = UIImageView()
    private let routineCategory: RoutineCategoryType?
    init(routineCategory: RoutineCategoryType?) {
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
        backgroundColor = routineCategory?.iconBackgroundColor ?? BitnagilColor.yellow10
        routineCategoryIcon.image = routineCategory?.iconImage ?? BitnagilIcon.shineIcon
    }

    private func configureLayout() {
        addSubview(routineCategoryIcon)
        routineCategoryIcon.snp.makeConstraints { make in
            make.size.equalTo(Layout.iconSize)
            make.center.equalToSuperview()
        }
    }
}
