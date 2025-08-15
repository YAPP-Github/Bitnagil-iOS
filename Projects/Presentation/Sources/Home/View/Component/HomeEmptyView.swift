//
//  HomeEmptyView.swift
//  Presentation
//
//  Created by 최정인 on 7/21/25.
//

import SnapKit
import UIKit

final class HomeEmptyView: UIView {
    private enum Layout {
        static let emptyMainLabelHeight: CGFloat = 28
        static let emptySubLabelHeight: CGFloat = 20
        static let emptySubLabelTopSpacing: CGFloat = 2
        static let registerRoutineButtonCornerRadius: CGFloat = 8
        static let registerRoutineButtonTopSpacing: CGFloat = 16
        static let registerRoutineButtonHeight: CGFloat = 36
        static let registerRoutineButtonWidth: CGFloat = 92
    }

    private let emptyMainLabel = UILabel()
    private let emptySubLabel = UILabel()
    private let registerRoutineButton = UIButton()
    var didTapRegisterRoutineButton: (() -> Void)?

    init() {
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Configures the visual appearance and interactive behavior of the view's subviews.
    /// 
    /// Sets text, fonts, alignment, and colors for `emptyMainLabel` and `emptySubLabel`, applies a filled `UIButton.Configuration` (title font, background and foreground colors) to `registerRoutineButton`, rounds its corners, and attaches the touch-up action that forwards to `didTapRegisterRoutine()`.
    private func configureAttribute() {
        emptyMainLabel.text = "등록한 루틴이 없어요"
        emptyMainLabel.font = BitnagilFont(style: .subtitle1, weight: .semiBold).font
        emptyMainLabel.textAlignment = .center
        emptyMainLabel.textColor = BitnagilColor.gray30

        emptySubLabel.text = "루틴을 등록하고, 작은 변화부터 시작해보세요!"
        emptySubLabel.font = BitnagilFont(style: .body2, weight: .regular).font
        emptySubLabel.textAlignment = .center
        emptySubLabel.textColor = BitnagilColor.gray70

        var configuration = UIButton.Configuration.filled()
        configuration.attributedTitle = AttributedString(
            "루틴 등록하기",
            attributes: .init([.font: BitnagilFont(style: .caption1, weight: .semiBold).font]))
        configuration.baseBackgroundColor = BitnagilColor.gray96
        configuration.baseForegroundColor = BitnagilColor.gray30
        registerRoutineButton.configuration = configuration
        registerRoutineButton.layer.masksToBounds = true
        registerRoutineButton.layer.cornerRadius = Layout.registerRoutineButtonCornerRadius
        registerRoutineButton.addAction(
            UIAction { [weak self] _ in
                self?.didTapRegisterRoutine()
            },
            for: .touchUpInside)
    }

    /// Configures the view hierarchy and Auto Layout constraints for the empty-state UI.
    /// 
    /// Adds `emptyMainLabel`, `emptySubLabel`, and `registerRoutineButton` as subviews and positions/sizes them using SnapKit constraints driven by the `Layout` constants. The constraints:
    /// - pin `emptyMainLabel` to the top and center it horizontally with a fixed height,
    /// - place `emptySubLabel` below `emptyMainLabel`, span its horizontal edges, center it, and set a fixed height,
    /// - position `registerRoutineButton` below `emptySubLabel`, center it, and set fixed height and width.
    private func configureLayout() {
        addSubview(emptyMainLabel)
        addSubview(emptySubLabel)
        addSubview(registerRoutineButton)

        emptyMainLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(Layout.emptyMainLabelHeight)
        }

        emptySubLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(emptyMainLabel.snp.bottom).offset(Layout.emptySubLabelTopSpacing)
            make.centerX.equalToSuperview()
            make.height.equalTo(Layout.emptySubLabelHeight)
        }

        registerRoutineButton.snp.makeConstraints { make in
            make.top.equalTo(emptySubLabel.snp.bottom).offset(Layout.registerRoutineButtonTopSpacing)
            make.centerX.equalToSuperview()
            make.height.equalTo(Layout.registerRoutineButtonHeight)
            make.width.equalTo(Layout.registerRoutineButtonWidth)
        }
    }

    private func didTapRegisterRoutine() {
        didTapRegisterRoutineButton?()
    }
}
