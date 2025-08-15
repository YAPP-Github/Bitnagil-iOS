//
//  DateView.swift
//  Presentation
//
//  Created by 최정인 on 7/23/25.
//

import Shared
import SnapKit
import UIKit

final class DateView: UIView {
    private enum Layout {
        static let dateButtonCornerRadius: CGFloat = 8
        static let dayLabelHeight: CGFloat = 18
        static let dateButtonTopSpacing: CGFloat = 7
        static let dateButtonSize: CGFloat = 30
        static let dateLabelHeight: CGFloat = 17
    }

    private let dayLabel = UILabel()
    private let dateButton = UIButton()
    private let dateLabel = UILabel()
    private let date: Date
    private let isToday: Bool
    private var isSelected: Bool {
        didSet {
            updateAttribute()
        }
    }
    var didTappedDateButton: ((Date) -> Void)?

    init(
        date: Date,
        isSelected: Bool = false,
        isToday: Bool = false
    ) {
        self.date = date
        self.isToday = isToday
        self.isSelected = isSelected
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()
        updateAttribute()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Configures the visual attributes and initial content of the view's subviews.
    /// 
    /// - Sets `dayLabel` text to `"오늘"` when `isToday` is true, otherwise to the date's day-of-week string.
    /// - Applies fonts, text color, and centered alignment for `dayLabel`.
    /// - Sets `dateLabel` text to the formatted date and applies its font and color.
    /// - Configures `dateButton` appearance (background color, corner radius, masking) and adds a `.touchUpInside` action that calls `selectDate()`.
    private func configureAttribute() {
        dayLabel.text = isToday ? "오늘" : "\(date.convertToString(dateType: .dayOfWeek))"
        dayLabel.font = BitnagilFont(style: .caption1, weight: .medium).font
        dayLabel.textColor = BitnagilColor.gray70
        dayLabel.textAlignment = .center

        dateButton.backgroundColor = .white
        dateButton.layer.masksToBounds = true
        dateButton.layer.cornerRadius = Layout.dateButtonCornerRadius
        dateButton.addAction(
            UIAction { [weak self] _ in
                self?.selectDate()
            },
            for: .touchUpInside)

        dateLabel.text = "\(date.convertToString(dateType: .date))"
        dateLabel.font = BitnagilFont(style: .body2, weight: .medium).font
        dateLabel.textColor = BitnagilColor.gray70
    }

    /// Sets up the view hierarchy and Auto Layout constraints for the subviews.
    /// 
    /// - Adds `dayLabel` and `dateButton` to the view and `dateLabel` inside `dateButton`.
    /// - Configures constraints (using SnapKit) to position:
    ///   - `dayLabel` pinned to the top/leading/trailing with a fixed height and width equal to `dateButton`.
    ///   - `dateButton` placed below `dayLabel`, aligned horizontally with a fixed size and top spacing.
    ///   - `dateLabel` centered inside `dateButton` with a fixed height.
    private func configureLayout() {
        addSubview(dayLabel)
        addSubview(dateButton)
        dateButton.addSubview(dateLabel)

        dayLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(Layout.dayLabelHeight)
            make.width.equalTo(dateButton.snp.width)
        }

        dateButton.snp.makeConstraints { make in
            make.top.equalTo(dayLabel.snp.bottom).offset(Layout.dateButtonTopSpacing)
            make.horizontalEdges.equalTo(dayLabel)
            make.size.equalTo(Layout.dateButtonSize)
        }

        dateLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(Layout.dateLabelHeight)
        }
    }

    /// Update visual appearance to reflect the current selection state.
    ///
    /// When `isSelected` is true, applies the selected fonts and colors (semiBold caption1 for `dayLabel`,
    /// semiBold body2 and white text for `dateLabel`, and a gray background for `dateButton`).
    /// When `isSelected` is false, applies the deselected fonts and colors (medium caption1 for `dayLabel`,
    /// medium body2 and gray text for `dateLabel`, and a clear background for `dateButton`).
    /// This method mutates the view's subviews (`dayLabel`, `dateLabel`, `dateButton`) only.
    private func updateAttribute() {
        let selectedDayLabelFont = BitnagilFont(style: .caption1, weight: .semiBold).font
        let deselectedDayLabelFont = BitnagilFont(style: .caption1, weight: .medium).font
        dayLabel.font = isSelected ? selectedDayLabelFont : deselectedDayLabelFont
        dayLabel.textColor = isSelected ? BitnagilColor.gray10 : BitnagilColor.gray70

        let selectedDateLabelFont = BitnagilFont(style: .body2, weight: .semiBold).font
        let deselectedDateLabelFont = BitnagilFont(style: .body2, weight: .medium).font
        dateLabel.font = isSelected ? selectedDateLabelFont : deselectedDateLabelFont
        dateLabel.textColor = isSelected ? .white : BitnagilColor.gray70

        dateButton.backgroundColor = isSelected ? BitnagilColor.gray10 : .clear
    }

    /// Notifies the selection handler that this date was tapped by calling `didTappedDateButton` with the view's `date`.
    /// If no handler is set, the call is ignored.
    private func selectDate() {
        didTappedDateButton?(date)
    }

    func updateSelectState(isSelected: Bool) {
        self.isSelected = isSelected
    }
}
