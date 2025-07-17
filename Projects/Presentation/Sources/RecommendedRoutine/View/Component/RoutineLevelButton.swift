//
//  LevelView.swift
//  Presentation
//
//  Created by 최정인 on 7/12/25.
//

import UIKit

final class RoutineLevelButton: UIButton {

    private enum Layout {
        static let stackViewSpacing: CGFloat = 5
        static let buttonLabelHeight: CGFloat = 20
        static let chevronImageSize: CGFloat = 12
        static let superViewInset: CGFloat = 10
        static let chevronIconSize: CGFloat = 16
    }

    private let stackView = UIStackView()
    private let buttonLabel = UILabel()
    private let chevronIcon = UIImageView()
    private var level: RoutineLevelType? = nil {
        didSet {
            updateButtonLabel()
        }
    }

    init() {
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureAttribute() {
        stackView.do {
            $0.isUserInteractionEnabled = false
            $0.axis = .horizontal
            $0.spacing = Layout.stackViewSpacing
        }

        buttonLabel.do {
            $0.text = level?.levelTitle ?? "난이도 선택"
            $0.font = BitnagilFont(style: .body2, weight: .medium).font
            $0.textColor = BitnagilColor.gray60
        }

        chevronIcon.do {
            $0.image = BitnagilIcon
                .chevronIcon(direction: .down)?
                .resizeAspectFit(to: CGSize(width: Layout.chevronImageSize, height: Layout.chevronImageSize))?
                .withRenderingMode(.alwaysTemplate)
            $0.contentMode = .center
            $0.tintColor = BitnagilColor.gray60
        }
    }

    private func configureLayout() {
        [buttonLabel, chevronIcon].forEach {
            stackView.addArrangedSubview($0)
        }
        addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Layout.superViewInset)
        }

        buttonLabel.snp.makeConstraints { make in
            make.height.equalTo(Layout.buttonLabelHeight)
        }

        chevronIcon.snp.makeConstraints { make in
            make.size.equalTo(Layout.chevronIconSize)
        }
    }

    private func updateButtonLabel() {
        buttonLabel.text = level?.levelTitle ?? "난이도 선택"
    }

    func updateButton(level: RoutineLevelType?) {
        self.level = level
    }
}
