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

    /// Configure visual and layout attributes for `dateStackView`.
    /// 
    /// Sets the stack view to horizontal axis, applies the predefined spacing, centers arranged views vertically, and uses equal spacing distribution.
    private func configureAttribute() {
        dateStackView.axis = .horizontal
        dateStackView.spacing = Layout.dateStackViewSpacing
        dateStackView.alignment = .center
        dateStackView.distribution = .equalSpacing
    }

    /// Configures the view's layout and constraints.
    /// 
    /// - Sets the view background color to `BitnagilColor.gray99`.
    /// - Adds `dateStackView` as a subview and pins it to the top of the view with horizontal margins defined by `Layout.horizontalMargin` and a fixed height `Layout.dateStackViewHeight`.
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

    /// Returns the Monday of the week that contains the given date.
    /// 
    /// If `date` falls on a Sunday, the function treats the previous Monday as the start of the week; for other weekdays it computes the offset back to Monday. If calendar arithmetic fails, the original `date` is returned as a fallback.
    /// - Parameter date: The date for which to compute the week's start (Monday).
    /// - Returns: A `Date` corresponding to the Monday of the same week as `date`, or `date` if the calculation fails.
    private func calculateWeekStartDate(for date: Date) -> Date {
        let weekday = calendar.component(.weekday, from: date)
        let daysFromMonday = (weekday == 1) ? 6 : weekday - 2
        return calendar.date(byAdding: .day, value: -daysFromMonday, to: date) ?? date
    }

    /// Rebuilds the seven day DateView items for the week containing `date` and updates selection state.
    /// 
    /// This clears any existing date views, computes the week's start (Monday) for the provided `date`,
    /// and creates seven `DateView` instances (one per day) which are added to `dateStackView` and
    /// stored in `dateViews`. Each `DateView` receives its initial `isSelected` and `isToday` state and
    /// a tap handler that routes selection to `selectDate(date:)`.
    /// 
    /// If the provided `date` is not the same day as the current `selectedDate`, `selectedDate` is set
    /// to the computed week start date before creating the views.
    /// - Parameter date: Any date within the week to display; the week start is computed from this value.
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

    /// Selects the given date as the current selection, updates the visible selection state, and notifies the delegate.
    /// - Parameters:
    ///   - date: The date to mark as selected (used to update `selectedDate` and refresh `DateView` selection states).
    private func selectDate(date: Date) {
        selectedDate = date
        updateSelectState()
        delegate?.weekView(self, didSelectDate: date)
    }

    /// Updates the selection state of each cached DateView to reflect the current `selectedDate`.
    /// 
    /// Iterates over `dateViews` and calls `updateSelectState(isSelected:)` on each `DateView`, setting `isSelected` to true when the mapped date is the same day as `selectedDate` according to the view's `calendar`.
    private func updateSelectState() {
        for (date, dateView) in dateViews {
            let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
            dateView.updateSelectState(isSelected: isSelected)
        }
    }
}
