//
//  WeekView.swift
//  Presentation
//
//  Created by 최정인 on 7/20/25.
//

import SnapKit
import UIKit

final class WeekView: UIView {

    private enum Layout {
        static let chevronIconSize: CGFloat = 13
        static let dateStackViewSpacing: CGFloat = 21
        static let monthLabelTopSpacing: CGFloat = 16
        static let horizontalMargin: CGFloat = 20
        static let moveMonthButtonSize: CGFloat = 48
        static let dateStackViewHeight: CGFloat = 79
        static let dateViewHeight: CGFloat = 55
    }

    private let monthLabel = UILabel()
    private let prevMonthButton = UIButton()
    private let nextMonthButton = UIButton()
    private let dateStackView = UIStackView()
    private var dateViews: [Date: DateView] = [:]
    private let calendar = Calendar.current

    private let today = Date()
    private var selectedDate = Date()
    private var currentWeekStartDate = Date()

    init() {
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()
        setupCurrentWeek()
        setWeekDateViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        monthLabel.text = "\(selectedDate.convertToString(dateType: .yearMonth))"
        monthLabel.font = BitnagilFont(style: .body1, weight: .semiBold).font
        monthLabel.textColor = BitnagilColor.gray10

        let leftIcon = BitnagilIcon
            .chevronIcon(direction: .left)?
            .resize(to: CGSize(width: Layout.chevronIconSize, height: Layout.chevronIconSize))
        prevMonthButton.setImage(leftIcon, for: .normal)
        prevMonthButton.tintColor = .black
        prevMonthButton.addAction(UIAction { [weak self] _ in
            self?.moveWeek(by: -1)
        }, for: .touchUpInside)

        let rightIcon = BitnagilIcon
            .chevronIcon(direction: .right)?
            .resize(to: CGSize(width: Layout.chevronIconSize, height: Layout.chevronIconSize))
        nextMonthButton.setImage(rightIcon, for: .normal)
        nextMonthButton.tintColor = .black
        nextMonthButton.addAction(UIAction { [weak self] _ in
            self?.moveWeek(by: 1)
        }, for: .touchUpInside)

        dateStackView.axis = .horizontal
        dateStackView.spacing = Layout.dateStackViewSpacing
        dateStackView.alignment = .center
        dateStackView.distribution = .equalSpacing
    }

    private func configureLayout() {
        backgroundColor = .systemBackground
        addSubview(monthLabel)
        addSubview(prevMonthButton)
        addSubview(nextMonthButton)
        addSubview(dateStackView)

        monthLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Layout.monthLabelTopSpacing)
            make.leading.equalToSuperview().offset(Layout.horizontalMargin)
        }

        prevMonthButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalTo(nextMonthButton.snp.leading)
            make.size.equalTo(Layout.moveMonthButtonSize)
        }

        nextMonthButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.size.equalTo(Layout.moveMonthButtonSize)
        }

        dateStackView.snp.makeConstraints { make in
            make.top.equalTo(nextMonthButton.snp.bottom)
            make.leading.equalToSuperview().offset(Layout.horizontalMargin)
            make.trailing.equalToSuperview().inset(Layout.horizontalMargin)
            make.height.equalTo(Layout.dateStackViewHeight)
        }
    }

    // 날짜 세팅 및 현재 주의 첫째날 세팅
    private func setupCurrentWeek() {
        selectedDate = today
        currentWeekStartDate = getWeekStartDate(for: today)
    }

    // 현재 주의 첫째 날을 뱉어줌
    private func getWeekStartDate(for date: Date) -> Date {
        let weekday = calendar.component(.weekday, from: date)
        let daysFromMonday = (weekday == 1) ? 6 : weekday - 2
        return calendar.date(byAdding: .day, value: -daysFromMonday, to: date) ?? date
    }

    // current 주에 맞춰 DateView들 세팅
    private func setWeekDateViews() {
        dateViews.values.forEach {
            $0.removeFromSuperview()
        }
        dateViews.removeAll()

        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: i, to: currentWeekStartDate)
            else { continue }

            let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
            let isToday = calendar.isDate(date, inSameDayAs: today)

            let dateView = DateView(date: date,
                                    isSelected: isSelected,
                                    isToday: isToday)
            dateView.didTappedDateButton = { [weak self] date in
                self?.dateSelected(date: date)
            }
            dateViews[date] = dateView
            dateStackView.addArrangedSubview(dateView)
            dateView.snp.makeConstraints { make in
                make.height.equalTo(Layout.dateViewHeight)
            }
        }
    }

    // 선택한 날짜의 dateView update
    private func updateSelectState() {
        for (date, dateView) in dateViews {
            let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
            dateView.updateSelectState(isSelected: isSelected)
        }
    }

    // 날짜 선택
    private func dateSelected(date: Date) {
        selectedDate = date
        updateMonthLabel()
        updateSelectState()
    }

    // month Label update
    private func updateMonthLabel() {
        monthLabel.text = selectedDate.convertToString(dateType: .yearMonth)
    }

    // 주를 움직여요
    private func moveWeek(by week: Int) {
        guard let newWeekStartDate = calendar.date(byAdding: .weekOfYear, value: week, to: currentWeekStartDate)
        else { return }
        currentWeekStartDate = newWeekStartDate

        selectedDate = currentWeekStartDate
        updateMonthLabel()
        setWeekDateViews()
    }
}
