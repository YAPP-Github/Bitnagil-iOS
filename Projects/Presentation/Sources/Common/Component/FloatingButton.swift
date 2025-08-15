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
        static let plusIconSize: CGFloat = 24
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

    /// Configures the button's visual appearance.
    /// 
    /// Sets the default background color, makes the layer circular by applying a corner radius and enabling masking, and assigns the plus icon image and its tint color.
    private func configureAttribute() {
        backgroundColor = BitnagilColor.orange500
        layer.masksToBounds = true
        layer.cornerRadius = Layout.floatingButtonHeight / 2

        plusIcon.image = BitnagilIcon.plusIcon
        plusIcon.tintColor = .white
    }

    /// Adds the plusIcon as a subview and installs its layout constraints.
    /// 
    /// The icon is sized to `Layout.plusIconSize` and centered within the button using SnapKit.
    private func configureLayout() {
        addSubview(plusIcon)

        plusIcon.snp.makeConstraints { make in
            make.size.equalTo(Layout.plusIconSize)
            make.center.equalToSuperview()
        }
    }

    /// Toggles the button's state and animates its appearance.
    /// 
    /// When called this flips `isToggled` and animates visual changes (0.3s, ease-in-out):
    /// - Toggled on: background → white, `plusIcon.tintColor` → `BitnagilColor.gray30`, icon rotated to -π/4.
    /// - Toggled off: background → `BitnagilColor.orange500`, `plusIcon.tintColor` → white, icon rotation reset to 0.
    func toggle() {
        isToggled.toggle()

        let angle: CGFloat = isToggled ? -.pi / 4 : 0
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
            self.backgroundColor = self.isToggled ? .white : BitnagilColor.orange500
            self.plusIcon.tintColor = self.isToggled ? BitnagilColor.gray30 : .white
            self.plusIcon.transform = CGAffineTransform(rotationAngle: angle)
        }
    }
}
