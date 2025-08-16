//
//  BitnagilCalendarView.swift
//  Presentation
//
//  Created by 이동현 on 8/16/25.
//

import FSCalendar
import SnapKit
import UIKit

protocol BitnagilCalendarViewDelegate: AnyObject {
    func bitnagilCalendarView(_ sender: BitnagilCalendarView, didSelectDate date: Date)
}

final class BitnagilCalendarView: UIViewController {
    private enum Layout {
        static let horizontalSpacing: CGFloat = 20
        static let chevronImageSize: CGFloat = 15
        static let monthMoveButtonSize: CGFloat = 48
        static let calendarHeaderHeight: CGFloat = 0
        static let calendarHeight: CGFloat = 323
        static let calendarTopSpacing: CGFloat = 15
        static let calendarHorizontalSpacing: CGFloat = 24
        static let confirmButtonHeight: CGFloat = 54
        static let confirmButtonTopSpacing: CGFloat = 27
        static let confirmButtonBottomSpacing: CGFloat = 14
    }

    private let dateLabel = UILabel()
    private let nextButton = UIButton()
    private let prevButton = UIButton()
    private let leftChevronImageView = UIImageView()
    private let rightChevronImageView = UIImageView()
    private var calendarView = FSCalendar()
    private let confirmButton = UIButton()

    var delegate: BitnagilCalendarViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAttribute()
        configureLayout()
    }

    private func configureAttribute() {
        configureCalendar()
        configureConfirmButton()

        let dateString = Date().convertToString(dateType: .yearMonth)
        dateLabel.text = dateString
        dateLabel.font = BitnagilFont.init(style: .title2, weight: .bold).font
        leftChevronImageView.image = BitnagilIcon
            .chevronIcon(direction: .left)?
            .withRenderingMode(.alwaysTemplate)
        rightChevronImageView.image = BitnagilIcon
            .chevronIcon(direction: .right)?
            .withRenderingMode(.alwaysTemplate)
        leftChevronImageView.tintColor = BitnagilColor.gray95
        rightChevronImageView.tintColor = BitnagilColor.gray10
        prevButton.backgroundColor = .clear
        nextButton.backgroundColor = .clear
    }

    private func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        view.addSubview(dateLabel)
        view.addSubview(leftChevronImageView)
        view.addSubview(rightChevronImageView)
        view.addSubview(prevButton)
        view.addSubview(nextButton)
        view.addSubview(calendarView)
        view.addSubview(confirmButton)

        dateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Layout.horizontalSpacing)
            make.centerY.equalTo(prevButton)
        }

        prevButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalTo(nextButton.snp.leading)
            make.size.equalTo(Layout.monthMoveButtonSize)
        }

        nextButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.size.equalTo(Layout.monthMoveButtonSize)
        }

        leftChevronImageView.snp.makeConstraints { make in
            make.size.equalTo(Layout.chevronImageSize)
            make.center.equalTo(prevButton)
        }

        rightChevronImageView.snp.makeConstraints { make in
            make.size.equalTo(Layout.chevronImageSize)
            make.center.equalTo(nextButton)
        }

        calendarView.snp.makeConstraints { make in
            make.top.equalTo(nextButton.snp.bottom).offset(Layout.calendarTopSpacing)
            make.horizontalEdges.equalToSuperview().inset(Layout.calendarHorizontalSpacing)
            make.height.equalTo(Layout.calendarHeight).priority(.medium)
        }

        confirmButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(Layout.horizontalSpacing)
            make.top.equalTo(calendarView.snp.bottom).offset(Layout.confirmButtonTopSpacing)
            make.bottom.equalTo(safeArea.snp.bottom).offset(-Layout.confirmButtonBottomSpacing)
            make.height.equalTo(Layout.confirmButtonHeight)
        }
    }

    private func configureCalendar() {
        calendarView.delegate = self
        calendarView.headerHeight = Layout.calendarHeaderHeight
        calendarView.appearance.weekdayTextColor = BitnagilColor.gray50
        calendarView.appearance.weekdayFont = BitnagilFont.init(style: .body2, weight: .semiBold).font
        calendarView.appearance.titleFont   = BitnagilFont.init(style: .subtitle1, weight: .regular).font
        calendarView.appearance.todayColor = .clear
        calendarView.appearance.titleTodayColor = .black
        calendarView.appearance.titleSelectionColor = BitnagilColor.orange500
        calendarView.appearance.selectionColor = BitnagilColor.orange50
        calendarView.appearance.borderRadius = 0.5

        calendarView.select(Date())
    }

    private func configureConfirmButton() {
        confirmButton.layer.cornerRadius = 12
        confirmButton.layer.masksToBounds = true
        confirmButton.backgroundColor = BitnagilColor.gray10
        confirmButton.titleLabel?.font = BitnagilFont.init(style: .body1, weight: .semiBold).font
        confirmButton.setTitle("확인", for: .normal)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                self.delegate?.bitnagilCalendarView(self, didSelectDate: Date())
                dismiss(animated: true)
            },
            for: .touchUpInside)
    }
}

extension BitnagilCalendarView: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        delegate?.bitnagilCalendarView(self, didSelectDate: date)
    }
}
