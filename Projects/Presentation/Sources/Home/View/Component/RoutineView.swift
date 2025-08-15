//
//  RoutineView.swift
//  Presentation
//
//  Created by 최정인 on 7/18/25.
//

import Shared
import SnapKit
import UIKit

protocol RoutineViewDelegate: AnyObject {
    func routineView(_ sender: RoutineView, didTapMainRoutineCheckButton mainRoutine: MainRoutine)
    func routineView(_ sender: RoutineView, didTapSubRoutineCheckButton subRoutine: SubRoutine)
}

final class RoutineView: UIView {
    private enum Layout {
        static let timeLabelHeight: CGFloat = 20
    }

    private let timeLabel = UILabel()
    private let containerView = UIView()
    private let mainRoutineView = UIView()
    private let mainRoutineLabel = UILabel()
    private let mainRoutineCheckButton = UIButton()
    private let grayLine = UIView()
    private let subRoutineStackView = UIStackView()

    private var isLayoutConfigured: Bool = false
    private var mainRoutineHeightConstraint: Constraint?
    private var routine: MainRoutine {
        didSet {
            updateRoutineState()
        }
    }
    weak var delegate: RoutineViewDelegate?
    init(routine: MainRoutine) {
        self.routine = routine
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Called during the view layout pass. Marks the view as having completed its one-time layout configuration on the first invocation by setting `isLayoutConfigured`, ensuring any idempotent setup tied to layout occurs only once. Also forwards to the superclass implementation.
    override func layoutSubviews() {
        super.layoutSubviews()

        guard !isLayoutConfigured else { return }
        isLayoutConfigured = true
    }

    override var intrinsicContentSize: CGSize {
        var baseHeight: CGFloat = 56
        if !routine.subRoutines.isEmpty {
            baseHeight = 100
            baseHeight += (34.0 * CGFloat(routine.subRoutines.count - 1))
        }
        return CGSize(width: UIView.noIntrinsicMetric, height: baseHeight)
    }

    /// Configure initial visual attributes and interactive behavior for the view's subviews.
    /// 
    /// - Sets display text, fonts, and colors for `timeLabel` and `mainRoutineLabel`.
    /// - Applies background color and corner radius to `containerView`.
    /// - Initializes `mainRoutineCheckButton` image and installs a touch action that toggles `routine.isDone`,
    ///   updates the internal `routine` state, and notifies the delegate via `routineView(_:didTapMainRoutineCheckButton:)`.
    /// - Sets `grayLine` visibility based on whether `routine.subRoutines` is empty.
    /// - Configures `subRoutineStackView` axis and spacing.
    private func configureAttribute() {
        timeLabel.text = routine.startTime.convertToString(dateType: .time24hour)
        timeLabel.font = BitnagilFont(style: .body2, weight: .medium).font
        timeLabel.textColor = BitnagilColor.gray10

        containerView.backgroundColor = .white
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 12

        mainRoutineLabel.text = routine.title
        mainRoutineLabel.font = BitnagilFont(style: .body1, weight: .semiBold).font
        mainRoutineLabel.textColor = BitnagilColor.gray10

        mainRoutineCheckButton.setImage(BitnagilIcon.uncheckedCircleIcon, for: .normal)
        mainRoutineCheckButton.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                var updatedRoutine = routine
                updatedRoutine.isDone.toggle()
                self.routine = updatedRoutine
                delegate?.routineView(self, didTapMainRoutineCheckButton: routine)
            },
            for: .touchUpInside)

        grayLine.backgroundColor = BitnagilColor.gray97
        grayLine.isHidden = routine.subRoutines.isEmpty

        subRoutineStackView.axis = .vertical
        subRoutineStackView.spacing = 10
    }

    /// Configures the view hierarchy and Auto Layout constraints for the RoutineView.
    ///
    — Builds and adds subviews (timeLabel, containerView, mainRoutineView, grayLine, subRoutineStackView),
    — lays out those subviews using SnapKit, and creates per-subroutine rows by calling `makeSubRoutineView(subRoutine:)`.
    /// 
    /// Side effects:
    /// - Adds all required subviews to the view hierarchy.
    /// - Installs SnapKit constraints for positioning and sizing.
    /// - Stores the main routine check button height constraint in `mainRoutineHeightConstraint`.
    /// - Adds each sub-routine view as an arranged subview of `subRoutineStackView`.
    private func configureLayout() {
        addSubview(timeLabel)
        addSubview(containerView)

        [mainRoutineLabel, mainRoutineCheckButton].forEach {
            mainRoutineView.addSubview($0)
        }
        containerView.addSubview(mainRoutineView)
        containerView.addSubview(grayLine)
        containerView.addSubview(subRoutineStackView)

        timeLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.height.equalTo(20)
        }

        containerView.snp.makeConstraints { make in
            make.top.trailing.bottom.equalToSuperview()
            make.leading.equalTo(timeLabel.snp.trailing).offset(8)
        }

        mainRoutineView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(8)
            make.height.equalTo(40)
        }

        mainRoutineLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalTo(211)
        }

        mainRoutineCheckButton.snp.makeConstraints { make in
            make.leading.equalTo(mainRoutineLabel.snp.trailing).offset(10)
            mainRoutineHeightConstraint = make.height.equalTo(40).constraint
            make.size.equalTo(40)
        }

        grayLine.snp.makeConstraints { make in
            make.top.equalTo(mainRoutineView.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(1)
        }

        for subRoutine in routine.subRoutines {
            let subRoutineView = makeSubRoutineView(subRoutine: subRoutine)
            subRoutineView.snp.makeConstraints { make in
                make.height.equalTo(24)
            }
            subRoutineStackView.addArrangedSubview(subRoutineView)
        }

        subRoutineStackView.snp.makeConstraints { make in
            make.top.equalTo(grayLine.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
        }
    }

    /// Creates a compact view representing a sub-routine row containing a check icon and its title.
    /// 
    /// The returned view contains a 24×24 check button aligned to the top-left and a label to its right.
    /// The check icon reflects `subRoutine.isDone` (checked or unchecked), and the label displays `subRoutine.title`.
    /// - Parameter subRoutine: The sub-routine model used to configure the check state and title.
    /// - Returns: A configured `UIView` containing the check button and title label.
    private func makeSubRoutineView(subRoutine: SubRoutine) -> UIView {
        let subRoutineView = UIView()
        let checkButton = UIButton()
        let subRoutineLabel = UILabel()

        subRoutineView.addSubview(checkButton)
        subRoutineView.addSubview(subRoutineLabel)

        let checkedIcon = BitnagilIcon.checkedCircleSmallIcon
        let uncheckedIcon = BitnagilIcon.uncheckedCircleSmallIcon
        checkButton.setImage(subRoutine.isDone ? checkedIcon : uncheckedIcon, for: .normal)

        checkButton.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.size.equalTo(24)
        }

        subRoutineLabel.text = subRoutine.title
        subRoutineLabel.font = BitnagilFont(style: .body2, weight: .medium).font
        subRoutineLabel.textColor = BitnagilColor.gray40

        subRoutineLabel.snp.makeConstraints { make in
            make.leading.equalTo(checkButton.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
        }

        return subRoutineView
    }

    /// Updates the main routine check button's image to reflect the current `routine.isDone` state.
    /// 
    /// Reads `routine.isDone` and sets `mainRoutineCheckButton` to the checked or unchecked circle icon accordingly. Intended to synchronize the button's visual state with the underlying routine model.
    func updateRoutineState() {
        let isDone = routine.isDone
        mainRoutineCheckButton.setImage(isDone ? BitnagilIcon.checkedCircleIcon : BitnagilIcon.uncheckedCircleIcon, for: .normal)
    }
}
