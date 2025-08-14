//
//  FloatingMenu.swift
//  Presentation
//
//  Created by 최정인 on 7/28/25.
//

import SnapKit
import UIKit

protocol FloatingMenuViewDelegate: AnyObject {
    func floatingMenuDidTapRegisterRoutineButton(_ sender: FloatingMenuView)
}

final class FloatingMenuView: UIView {
    private enum Layout {
        static let registerRoutineButtonHeight: CGFloat = 24
        static let registerRoutineIconSize: CGFloat = 24
        static let registerRoutineLabelLeadingSpacing: CGFloat = 14
        static let registerRoutineButtonWidth: CGFloat = 112
        static let registerRoutineLabelHeight: CGFloat = 20
    }

    private let containerView = UIView()
    private let registerRoutineButton = UIButton()
    private let registerRoutineIconView = UIImageView()
    private let registerRoutineLabel = UILabel()
    weak var delegate: FloatingMenuViewDelegate?

    init() {
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        containerView.backgroundColor = .white
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 12

        registerRoutineIconView.image = BitnagilIcon.addRoutineIcon

        registerRoutineLabel.text = "루틴 등록"
        registerRoutineLabel.font = BitnagilFont(style: .body2, weight: .medium).font
        registerRoutineLabel.textColor = BitnagilColor.gray30

        registerRoutineButton.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                self.delegate?.floatingMenuDidTapRegisterRoutineButton(self)
            },
            for: .touchUpInside)
    }

    private func configureLayout() {
        addSubview(containerView)
        containerView.addSubview(registerRoutineButton)
        [registerRoutineIconView, registerRoutineLabel].forEach {
            registerRoutineButton.addSubview($0)
        }

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        registerRoutineButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(Layout.registerRoutineButtonHeight)
            make.width.equalTo(Layout.registerRoutineButtonWidth)
        }

        registerRoutineIconView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
            make.size.equalTo(Layout.registerRoutineIconSize)
        }

        registerRoutineLabel.snp.makeConstraints { make in
            make.leading.equalTo(registerRoutineIconView.snp.trailing).offset(Layout.registerRoutineLabelLeadingSpacing)
            make.centerY.equalToSuperview()
            make.height.equalTo(Layout.registerRoutineLabelHeight)
        }
    }
}
