//
//  MainRoutineView.swift
//  Presentation
//
//  Created by 최정인 on 7/18/25.
//

import UIKit

protocol MainRoutineViewDelegate: AnyObject {
    func mainRoutineView(_ sender: MainRoutineView, didTapCheckButton mainRoutine: MainRoutine)
    func mainRoutineView(_ sender: MainRoutineView, didTapMoreButton mainRoutine: MainRoutine)
}

final class MainRoutineView: UIView {

    private enum Layout {
        static let cornerRadius: CGFloat = 8
        static let checkBoxCornerRadius: CGFloat = 5.33
        static let checkIconSize: CGFloat = 24
        static let buttonStackViewSpacing: CGFloat = 12
        static let checkButtonHeight: CGFloat = 43
        static let checkButtonWidth: CGFloat = 165
        static let checkButtonLeadingSpacing: CGFloat = 16
        static let moreButtonTrailingSpacing: CGFloat = 5
        static let moreButtonSize: CGFloat = 24
    }

    private let mainLabel = UILabel()
    private let checkButton = UIButton()
    private let buttonStackView = UIStackView()
    private let checkBackgroundView = UIView()
    private let checkIcon = UIImageView()
    private let moreButton = UIButton()

    private var mainRoutine: MainRoutine {
        didSet {
            updateAttribute()
        }
    }
    weak var delegate: MainRoutineViewDelegate?

    init(mainRoutine: MainRoutine) {
        self.mainRoutine = mainRoutine
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureAttribute() {
        backgroundColor = BitnagilColor.lightBlue75
        layer.masksToBounds = true
        layer.cornerRadius = Layout.cornerRadius

        mainLabel.text = mainRoutine.title
        mainLabel.font = BitnagilFont(style: .subtitle1, weight: .semiBold).font
        mainLabel.textColor = BitnagilColor.navy500

        checkButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.delegate?.mainRoutineView(self, didTapCheckButton: mainRoutine)
        }, for: .touchUpInside)

        buttonStackView.axis = .horizontal
        buttonStackView.spacing = Layout.buttonStackViewSpacing
        buttonStackView.alignment = .center
        buttonStackView.isUserInteractionEnabled = false

        checkBackgroundView.backgroundColor = .white
        checkBackgroundView.layer.masksToBounds = true
        checkBackgroundView.layer.cornerRadius = Layout.checkBoxCornerRadius

        checkIcon.image = BitnagilIcon.checkIcon
        checkIcon.tintColor = BitnagilColor.navy50

        moreButton.setImage(BitnagilIcon.ellipsisIcon, for: .normal)
        moreButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.delegate?.mainRoutineView(self, didTapMoreButton: mainRoutine)
        }, for: .touchUpInside)
    }

    private func configureLayout() {
        [checkBackgroundView, mainLabel].forEach {
            buttonStackView.addArrangedSubview($0)
        }
        checkBackgroundView.addSubview(checkIcon)
        checkButton.addSubview(buttonStackView)
        addSubview(checkButton)
        addSubview(moreButton)

        checkBackgroundView.snp.makeConstraints { make in
            make.size.equalTo(Layout.checkIconSize)
        }

        checkIcon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(Layout.checkIconSize)
        }

        checkButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(Layout.checkButtonLeadingSpacing)
            make.height.equalTo(Layout.checkButtonHeight)
        }

        buttonStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        moreButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(Layout.moreButtonTrailingSpacing)
            make.size.equalTo(Layout.moreButtonSize)
        }
    }

    private func updateAttribute() {
        let isDone = mainRoutine.isDone
        checkIcon.tintColor = isDone ? BitnagilColor.navy500 : BitnagilColor.navy50
    }

    func updateState(isDone: Bool) {
        mainRoutine.isDone = isDone
    }
}
