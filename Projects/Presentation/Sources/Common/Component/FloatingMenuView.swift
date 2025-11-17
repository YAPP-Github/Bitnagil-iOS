//
//  FloatingMenu.swift
//  Presentation
//
//  Created by 최정인 on 7/28/25.
//

import SnapKit
import UIKit

protocol FloatingMenuViewDelegate: AnyObject {
    func floatingMenuDidTapReportButton(_ sender: FloatingMenuView)
    func floatingMenuDidTapRegisterRoutineButton(_ sender: FloatingMenuView)
}

final class FloatingMenuView: UIView {
    private enum Layout {
        static let menuButtonStackViewSpacing: CGFloat = 24
        static let menuButtonHeight: CGFloat = 24
        static let menuIconSize: CGFloat = 24
        static let menuLabelLeadingSpacing: CGFloat = 14
        static let menuButtonWidth: CGFloat = 112
        static let menuLabelHeight: CGFloat = 20
    }

    private enum FloatingMenu {
        case addRoutine
        case report

        var menuIcon: UIImage? {
            switch self {
            case .addRoutine:
                return BitnagilIcon.addRoutineIcon
            case .report:
                return BitnagilIcon.reportIcon
            }
        }

        var menuLabel: String {
            switch self {
            case .addRoutine:
                return "루틴 등록"
            case .report:
                return "제보하기"
            }
        }
    }

    private let containerView = UIView()
    private let menuButtonStackView = UIStackView()
    private var reportButton = UIButton()
    private var registerRoutineButton = UIButton()
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

        menuButtonStackView.axis = .vertical
        menuButtonStackView.spacing = Layout.menuButtonStackViewSpacing

        reportButton = makeMenuButton(menu: .report)
        reportButton.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                self.delegate?.floatingMenuDidTapReportButton(self)
            },
            for: .touchUpInside)

        registerRoutineButton = makeMenuButton(menu: .addRoutine)
        registerRoutineButton.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                self.delegate?.floatingMenuDidTapRegisterRoutineButton(self)
            },
            for: .touchUpInside)
    }

    private func configureLayout() {
        addSubview(containerView)
        [reportButton, registerRoutineButton].forEach { menuButton in
            menuButtonStackView.addArrangedSubview(menuButton)
        }
        containerView.addSubview(menuButtonStackView)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        menuButtonStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }

        reportButton.snp.makeConstraints { make in
            make.height.equalTo(Layout.menuButtonHeight)
            make.width.equalTo(Layout.menuButtonWidth)
        }

        registerRoutineButton.snp.makeConstraints { make in
            make.height.equalTo(Layout.menuButtonHeight)
            make.width.equalTo(Layout.menuButtonWidth)
        }
    }

    private func makeMenuButton(menu: FloatingMenu) -> UIButton {
        let menuButton = UIButton()
        let menuIconView = UIImageView()
        let menuLabel = UILabel()

        menuIconView.image = menu.menuIcon
        menuLabel.text = menu.menuLabel
        menuLabel.font = BitnagilFont(style: .body2, weight: .medium).font
        menuLabel.textColor = BitnagilColor.gray30

        [menuIconView, menuLabel].forEach {
            menuButton.addSubview($0)
        }

        menuIconView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
            make.size.equalTo(Layout.menuIconSize)
        }

        menuLabel.snp.makeConstraints { make in
            make.leading.equalTo(menuIconView.snp.trailing).offset(Layout.menuLabelLeadingSpacing)
            make.centerY.equalToSuperview()
            make.height.equalTo(Layout.menuLabelHeight)
        }

        return menuButton
    }
}
