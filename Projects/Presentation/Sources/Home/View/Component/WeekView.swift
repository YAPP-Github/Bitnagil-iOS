//
//  WeekView.swift
//  Presentation
//
//  Created by 최정인 on 7/20/25.
//

import SnapKit
import UIKit

protocol WeekViewDelegate: AnyObject {
    func weekView(_ sender: WeekView, didSelectDate date: Date)
}

final class WeekView: UIView {
    private enum Layout {
        static let dateStackViewSpacing: CGFloat = 21
        static let horizontalMargin: CGFloat = 20
        static let dateStackViewHeight: CGFloat = 72
        static let dateViewHeight: CGFloat = 55
    }

    private let dateStackView = UIStackView()
    private var dateViews: [Date: DateView] = [:]
    private let calendar = Calendar.current
    private var selectedDate: Date
    weak var delegate: WeekViewDelegate?

    init(date: Date = Date()) {
        self.selectedDate = date
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()
        updateWeekDateViews(date: date)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        dateStackView.axis = .horizontal
        dateStackView.spacing = Layout.dateStackViewSpacing
        dateStackView.alignment = .center
        dateStackView.distribution = .equalSpacing
    }

    private func configureLayout() {
        backgroundColor = BitnagilColor.gray99
        addSubview(dateStackView)

        dateStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(Layout.horizontalMargin)
            make.trailing.equalToSuperview().inset(Layout.horizontalMargin)
            make.height.equalTo(Layout.dateStackViewHeight)
        }
    }

    // 현재 주의 첫째 날을 계산해줍니다.
    private func calculateWeekStartDate(for date: Date) -> Date {
        let weekday = calendar.component(.weekday, from: date)
        let daysFromMonday = (weekday == 1) ? 6 : weekday - 2
        return calendar.date(byAdding: .day, value: -daysFromMonday, to: date) ?? date
    }

    // 현재 주에 맞춰 DateView들 업데이트합니다.
    func updateWeekDateViews(date: Date) {
        dateViews.values.forEach {
            $0.removeFromSuperview()
        }
        dateViews.removeAll()

        let weekStartDate = calculateWeekStartDate(for: date)
        let isSelectedDay = calendar.isDate(selectedDate, equalTo: date, toGranularity: .day)
        if !isSelectedDay {
            selectedDate = weekStartDate
        }
        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: i, to: weekStartDate)
            else { continue }

            let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
            let isToday = calendar.isDate(date, inSameDayAs: Date())

            let dateView = DateView(
                date: date,
                isSelected: isSelected,
                isToday: isToday)

            dateView.didTappedDateButton = { [weak self] date in
                self?.selectDate(date: date)
            }
            
            dateViews[date] = dateView
            dateStackView.addArrangedSubview(dateView)
            dateView.snp.makeConstraints { make in
                make.height.equalTo(Layout.dateViewHeight)
            }
        }
    }

    // 날짜를 선택합니다.
    private func selectDate(date: Date) {
        selectedDate = date
        updateSelectState()
        delegate?.weekView(self, didSelectDate: date)
    }

    // 선택한 날짜의 dateView를 업데이트합니다.
    private func updateSelectState() {
        for (date, dateView) in dateViews {
            let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
            dateView.updateSelectState(isSelected: isSelected)
        }
    }
}
