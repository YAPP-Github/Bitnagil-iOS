//
//  FloatingButton.swift
//  Presentation
//
//  Created by 최정인 on 7/28/25.
//

import SnapKit
import UIKit

final class FloatingButton: UIButton {

    private enum Layout {
        static let floatingButtonHeight: CGFloat = 52
        static let plusIconSize: CGFloat = 15
    }

    private let plusIcon = UIImageView()
    private var isToggled: Bool = false

    init() {
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        backgroundColor = BitnagilColor.navy500
        layer.masksToBounds = true
        layer.cornerRadius = Layout.floatingButtonHeight / 2

        plusIcon.image = BitnagilIcon.plusIcon
        plusIcon.tintColor = BitnagilColor.gray99
    }

    private func configureLayout() {
        addSubview(plusIcon)

        plusIcon.snp.makeConstraints { make in
            make.size.equalTo(Layout.plusIconSize)
            make.center.equalToSuperview()
        }
    }

    func toggle() {
        isToggled.toggle()

        let angle: CGFloat = isToggled ? -.pi / 4 : 0
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
            self.plusIcon.transform = CGAffineTransform(rotationAngle: angle)
        }
    }
}
