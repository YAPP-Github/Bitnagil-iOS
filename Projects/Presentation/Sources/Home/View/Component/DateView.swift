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

    private func configureAttribute() {
        dayLabel.text = isToday ? "오늘" : "\(date.convertToString(dateType: .dayOfWeek))"
        dayLabel.font = BitnagilFont(style: .caption1, weight: .medium).font
        dayLabel.textColor = BitnagilColor.gray70
        dayLabel.textAlignment = .center

        dateButton.backgroundColor = .white
        dateButton.layer.masksToBounds = true
        dateButton.layer.cornerRadius = Layout.dateButtonCornerRadius
        dateButton.addAction(UIAction { [weak self] _ in
            self?.selectDate()
        }, for: .touchUpInside)

        dateLabel.text = "\(date.convertToString(dateType: .date))"
        dateLabel.font = BitnagilFont(style: .body2, weight: .medium).font
        dateLabel.textColor = BitnagilColor.gray70
    }

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

    private func updateAttribute() {
        dayLabel.textColor = isSelected ? BitnagilColor.gray10 : BitnagilColor.gray70
        dateLabel.textColor = isSelected ? BitnagilColor.gray10 : BitnagilColor.gray70
        dateButton.backgroundColor = isSelected ? BitnagilColor.lightBlue100 : .white
    }

    private func selectDate() {
        didTappedDateButton?(date)
    }

    func updateSelectState(isSelected: Bool) {
        self.isSelected = isSelected
    }
}
