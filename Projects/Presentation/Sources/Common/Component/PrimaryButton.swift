//
//  PrimaryButton.swift
//  Presentation
//
//  Created by 최정인 on 7/6/25.
//

import UIKit

final class PrimaryButton: UIButton {

    enum ButtonState {
        case `default`
        case hover
        case pressed
        case disabled

        var buttonColor: UIColor? {
            switch self {
            case .default: BitnagilColor.navy500
            case .hover: BitnagilColor.navy700
            case .pressed: BitnagilColor.navy700
            case .disabled: BitnagilColor.navy50
            }
        }

        var buttonTextColor: UIColor? {
            switch self {
            case .default: .white
            case .hover: .white
            case .pressed: BitnagilColor.navy400
            case .disabled: BitnagilColor.gray70
            }
        }
    }

    private var buttonState: ButtonState {
        didSet {
            updateButtonUI()
        }
    }

    init(buttonState: ButtonState, buttonTitle: String) {
        self.buttonState = buttonState
        super.init(frame: .zero)
        configureAttribute(buttonTitle: buttonTitle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateButtonState(buttonState: ButtonState) {
        self.buttonState = buttonState
        self.isEnabled = buttonState != .disabled
    }

    private func configureAttribute(buttonTitle: String) {
        setTitle(buttonTitle, for: .normal)
        titleLabel?.font = BitnagilFont(style: .body1, weight: .semiBold).font
        layer.cornerRadius = 12
        updateButtonUI()
    }

    private func updateButtonUI() {
        setTitleColor(buttonState.buttonTextColor, for: .normal)
        backgroundColor = buttonState.buttonColor
    }
}
