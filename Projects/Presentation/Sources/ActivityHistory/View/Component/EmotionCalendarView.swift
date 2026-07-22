//
//  EmotionCalendarView.swift
//  Presentation
//
//  Created by 최정인 on 7/3/26.
//

import Combine
import FSCalendar
import Shared
import SnapKit
import UIKit

final class EmotionCalendarView: UIView {
    private enum Layout {
        static let calendarHeaderHeight: CGFloat = 0
        static let calendarWeekdayHeight: CGFloat = 46
        static let headerStackViewSpacing: CGFloat = 0
        static let headerStackViewHeight: CGFloat = 48
        static let moveMonthButtonImageSize: CGFloat = 18
        static let moveMonthButtonSize: CGFloat = 48
        static let calendarTopSpacing: CGFloat = 24
    }

    private let headerStackView = UIStackView()
    private let previousMonthButtonImage = UIImageView()
    private let previousMonthButton = UIButton()
    private let monthLabel = UILabel()
    private let nextMonthButtonImage = UIImageView()
    private let nextMonthButton = UIButton()
    private let calendar = FSCalendar()

    let dateSelected = PassthroughSubject<(date: Date, emotion: EmotionMarble?), Never>()
    let pageChanged = PassthroughSubject<Date, Never>()
    private var emotionRecords: [String: EmotionMarble] = [:]
    private let cellIdentifier = "EmotionCalendarCell"

    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()
        updateMonthLabel(date: calendar.currentPage)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureAttribute() {
        calendar.register(EmotionCalendarCell.self, forCellReuseIdentifier: cellIdentifier)
        calendar.dataSource = self
        calendar.delegate = self

        calendar.appearance.todayColor = .clear
        calendar.appearance.titleTodayColor = nil
        calendar.appearance.selectionColor = .clear

        calendar.headerHeight = Layout.calendarHeaderHeight
        calendar.appearance.weekdayFont = BitnagilFont(style: .body2, weight: .semiBold).font
        calendar.appearance.weekdayTextColor = BitnagilColor.gray50

        calendar.placeholderType = .fillHeadTail
        calendar.scope = .month
        calendar.weekdayHeight = Layout.calendarWeekdayHeight

        headerStackView.axis = .horizontal
        headerStackView.spacing = Layout.headerStackViewSpacing
        headerStackView.alignment = .center

        previousMonthButtonImage.image = UIImage(systemName: "chevron.left")
        previousMonthButtonImage.tintColor = BitnagilColor.gray10
        previousMonthButtonImage.contentMode = .scaleAspectFit
        previousMonthButton.addTarget(self, action: #selector(moveToPreviousMonth), for: .touchUpInside)

        nextMonthButtonImage.image = UIImage(systemName: "chevron.right")
        nextMonthButtonImage.tintColor = BitnagilColor.gray10
        nextMonthButtonImage.contentMode = .scaleAspectFit
        nextMonthButton.addTarget(self, action: #selector(moveToNextMonth), for: .touchUpInside)

        monthLabel.font = BitnagilFont(style: .subtitle1, weight: .semiBold).font
        monthLabel.textColor = BitnagilColor.gray30
        monthLabel.textAlignment = .center
    }

    private func configureLayout() {
        addSubview(headerStackView)
        addSubview(calendar)

        previousMonthButton.addSubview(previousMonthButtonImage)
        nextMonthButton.addSubview(nextMonthButtonImage)
        [previousMonthButton, monthLabel, nextMonthButton].forEach {
            headerStackView.addArrangedSubview($0)
        }

        headerStackView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.height.equalTo(Layout.headerStackViewHeight)
        }

        previousMonthButtonImage.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(Layout.moveMonthButtonImageSize)
        }

        previousMonthButton.snp.makeConstraints { make in
            make.size.equalTo(Layout.moveMonthButtonSize)
        }

        nextMonthButtonImage.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(Layout.moveMonthButtonImageSize)
        }

        nextMonthButton.snp.makeConstraints { make in
            make.size.equalTo(Layout.moveMonthButtonSize)
        }

        calendar.snp.makeConstraints { make in
            make.top.equalTo(headerStackView.snp.bottom).offset(Layout.calendarTopSpacing)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }

    func update(records: [String: EmotionMarble]) {
        self.emotionRecords = records
        calendar.reloadData()
    }

    @objc private func moveToPreviousMonth() {
        guard let newMonth = Calendar.current.date(byAdding: .month, value: -1, to: calendar.currentPage)
        else { return }
        
        calendar.setCurrentPage(newMonth, animated: true)
    }

    @objc private func moveToNextMonth() {
        guard let newMonth = Calendar.current.date(byAdding: .month, value: 1, to: calendar.currentPage)
        else { return }

        calendar.setCurrentPage(newMonth, animated: true)
    }

    private func updateMonthLabel(date: Date) {
        monthLabel.text = date.convertToString(dateType: .yearMonthShort)
    }

    private func isInCurrentMonth(date: Date) -> Bool {
        return Calendar.current.isDate(date, equalTo: calendar.currentPage, toGranularity: .month)
    }
}

// MARK: - FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance
extension EmotionCalendarView: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    func calendar(
        _ calendar: FSCalendar,
        appearance: FSCalendarAppearance,
        titleDefaultColorFor date: Date
    ) -> UIColor? {
        guard isInCurrentMonth(date: date)
        else { return BitnagilColor.gray80 }

        let key = date.convertToString(dateType: .yearMonthDate)
        guard let emotion = emotionRecords[key] else { return BitnagilColor.gray30 }
        return emotion.marble.textColor
    }

    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        guard let cell = calendar.dequeueReusableCell(
            withIdentifier: cellIdentifier,
            for: date,
            at: position) as? EmotionCalendarCell
        else { return FSCalendarCell() }

        let key = date.convertToString(dateType: .yearMonthDate)
        guard let emotion = emotionRecords[key] else { return cell }

        if isInCurrentMonth(date: date) {
            cell.configure(backgroundColor: emotion.marble.backgroundColor)
        } else {
            cell.configure(backgroundColor: BitnagilColor.gray98, isRecorded: false)
        }
        return cell
    }

    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        let key = date.convertToString(dateType: .yearMonthDate)
        return emotionRecords[key] != nil
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let key = date.convertToString(dateType: .yearMonthDate)
        let emotion = emotionRecords[key]

        guard let emotion else {
            calendar.deselect(date)
            return
        }

        if !isInCurrentMonth(date: date) {
            calendar.setCurrentPage(date, animated: true)
        }
        dateSelected.send((date: date, emotion: emotion))
        calendar.deselect(date)
    }

    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        updateMonthLabel(date: calendar.currentPage)
        pageChanged.send(calendar.currentPage)
    }
}
