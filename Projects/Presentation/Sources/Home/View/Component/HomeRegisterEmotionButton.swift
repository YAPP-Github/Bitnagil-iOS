//
//  HomeRegisterEmotionButton.swift
//  Presentation
//
//  Created by 최정인 on 7/21/25.
//

import UIKit

final class HomeRegisterEmotionButton: UIButton {
    enum ButtonState {
        case `default`
        case tap
        case disabled

        var buttonBackgroudColor: UIColor? {
            switch self {
            case .default: BitnagilColor.orange500
            case .tap: BitnagilColor.orange600
            case .disabled: BitnagilColor.gray30
            }
        }

        var buttonTextColor: UIColor? {
            switch self {
            case .default: .white
            case .tap: .white
            case .disabled: BitnagilColor.gray10
            }
        }

        var buttonTitle: String {
            switch self {
            case .default, .tap: "오늘 감정 등록하기"
            case .disabled: "오늘 감정 등록완료"
            }
        }
    }

    private var buttonState: ButtonState = .default {
        didSet {
            updateButtonUI()
        }
    }

    init() {
        super.init(frame: .zero)
        configureAttribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Configure the button's static visual attributes.
    /// 
    /// Sets layer properties (corner radius, masks), initial background color based on the current `buttonState`,
    /// the title font, and the titles and title colors for the normal, highlighted, and disabled control states.
    private func configureAttribute() {
        layer.masksToBounds = true
        layer.cornerRadius = 8

        backgroundColor = buttonState.buttonBackgroudColor
        titleLabel?.font = BitnagilFont(style: .body2, weight: .semiBold).font

        setTitle("오늘 감정 등록하기", for: .normal)
        setTitleColor(ButtonState.default.buttonTextColor, for: .normal)

        setTitle("오늘 감정 등록하기", for: .highlighted)
        setTitleColor(ButtonState.tap.buttonTextColor, for: .highlighted)

        setTitle("오늘 감정 등록완료", for: .disabled)
        setTitleColor(ButtonState.disabled.buttonTextColor, for: .disabled)
    }

    /// Update the button's appearance to match the current `buttonState`.
    ///
    /// Sets the button's `backgroundColor` to `buttonState.buttonBackgroudColor`.
    private func updateButtonUI() {
        backgroundColor = buttonState.buttonBackgroudColor
    }

    /// Updates the button's visual state and enabled status.
    /// - Parameter buttonState: The new visual state to apply; sets the internal state, updates the UI, and disables the control when `.disabled`.
    func updateButtonState(buttonState: ButtonState) {
        self.buttonState = buttonState
        self.isEnabled = buttonState != .disabled
    }
}
