//
//  EmotionCalendarCell.swift
//  Presentation
//
//  Created by 최정인 on 7/7/26.
//

import FSCalendar
import UIKit

final class EmotionCalendarCell: FSCalendarCell {
    private let circleView = UIView()
    private let circleSize: CGFloat = 34
    private var isRecorded: Bool = false

    override init!(frame: CGRect) {
        super.init(frame: frame)
        configureAttribute()
    }
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureAttribute() {
        circleView.isUserInteractionEnabled = false
        contentView.insertSubview(circleView, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let center = titleLabel.center
        circleView.frame = CGRect(
            x: center.x - circleSize / 2,
            y: center.y - circleSize / 2,
            width: circleSize,
            height: circleSize)
        circleView.layer.cornerRadius = circleSize / 2
    }

    override func configureAppearance() {
        super.configureAppearance()
        titleLabel.font = isRecorded ? BitnagilFont(style: .subtitle1, weight: .semiBold).font : BitnagilFont(style: .subtitle1, weight: .regular).font
    }

    func configure(backgroundColor: UIColor?, isRecorded: Bool = true) {
        circleView.backgroundColor = backgroundColor
        self.isRecorded = isRecorded
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        circleView.backgroundColor = .clear
        isRecorded = false
    }
}
