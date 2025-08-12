//
//  RoutineCreationViewController.swift
//  Presentation
//
//  Created by 이동현 on 7/20/25.
//

import Combine
import SnapKit
import UIKit

final class RoutineCreationView: BaseViewController<RoutineCreationViewModel> {
    private enum Layout {
        static let horizontalInset: CGFloat = 20
        static let nameTitleLabelTopSpacing: CGFloat = 32
        static let titleLabelHeight: CGFloat = 24
        static let titleLabelTopSpacing: CGFloat = 40
        static let titleLabelBottomSpacing: CGFloat = 14
        static let titleAsteriskTopSpacing: CGFloat = 2
        static let titleAsteriskLeadingSpacing: CGFloat = 2
        static let titleAsteriskHeight: CGFloat = 24
        static let titleAsteriskWidth: CGFloat = 9
        static let inputViewHeight: CGFloat = 52
        static let subroutineStackViewHeight: CGFloat = 0
        static let subroutineStackViewSpacing: CGFloat = 10
        static let warningLabelTopSpacing: CGFloat = 8
        static let warningLabelHeight: CGFloat = 18
        static let repeatButtonHeight: CGFloat = 52
        static let repeatWeekDayButtonLeadingSpacing: CGFloat = 13
        static let infoButtonSize: CGFloat = 16
        static let infoButtonLeadingSpacing: CGFloat = 6
        static let tooltipViewHeight: CGFloat = 47
        static let tooltipViewLeadingSpacing: CGFloat = 22
        static let tooltipViewBottomSpacing: CGFloat = 8
        static let tooltipViewTailLeadingSpacing: CGFloat = 16
        static let detailTooltipWidth: CGFloat = 209
        static let repeatTooltipWidth: CGFloat = 262
        static let weekDayStackViewTopSpacing: CGFloat = 16
        static let weekDayStackViewSpacing: CGFloat = 10
        static let weekDayStackViewHeight: CGFloat = 48
        static let allDayButtonSize: CGFloat = 20
        static let allDayButtonTrailingSpacing: CGFloat = 6
        static let allDayLabelWidth: CGFloat = 55
        static let registerButtonTopSpacing: CGFloat = 54
        static let registerButtonHeight: CGFloat = 54
        static let registerButtonBottomSpacing: CGFloat = 14
        static let datePickerBottomSheetHeight: CGFloat = 347
    }

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let nameTitleLabel = UILabel()
    private let nameAsterisk = UIImageView()
    private let nameInputView = RoutineCreationInputView()

    private let detailTitleLabel = UILabel()
    private let detailInfoButton = UIButton()
    private let subroutineAdditionButton = SubroutineAdditionButton()
    private let subroutineStackView = UIStackView()
    private let detailWarningLabel = UILabel()
    private let detailToolTipView = TooltipView(tailPosition: .offsetFromLeading(Layout.tooltipViewTailLeadingSpacing))

    private let repeatTitleLabel = UILabel()
    private let repeatInfoButton = UIButton()
    private let repeatToolTipView = TooltipView(tailPosition: .offsetFromLeading(Layout.tooltipViewTailLeadingSpacing))
    private let repeatDailyButton = UIButton()
    private let repeatWeekButton = UIButton()

    private let startTimeTitleLabel = UILabel()
    private let startTimeAsterisk = UIImageView()
    private let timePickerButton = RoutineTimePickerButton()
    private let allDayButton = UIButton()
    private let allDayLabelButton = UIButton()
    private let allDayLabel = UILabel()
    private let weekdaysStackView = UIStackView()

    private let registerButton = UIButton()

    private let navigationTitle: String
    private let registerButtonTitle: String
    private var repeatRoutineTitleTopConstraint: Constraint?
    private var startTimeTitleTopConstraint: Constraint?

    private var cancellables = Set<AnyCancellable>()

    init(viewModel: RoutineCreationViewModel, routineId: String? = nil) {
        navigationTitle = routineId == nil ? "루틴 등록" : "루틴 수정"
        registerButtonTitle = routineId == nil ? "등록하기" : "수정하기"

        super.init(viewModel: viewModel)
        if let routineId {
            viewModel.action(input: .fetchRoutine(id: routineId))
        }
    }

    init(viewModel: RoutineCreationViewModel, recommendRoutineId: Int) {
        navigationTitle = "루틴 등록"
        registerButtonTitle = "등록하기"

        super.init(viewModel: viewModel)
        viewModel.action(input: .fetchRecommendedRoutine(id: recommendRoutineId))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        configureNavigationBar(navigationStyle: .withBackButton(title: navigationTitle))
    }

    override func configureAttribute() {
        configureSubroutineStackView()
        configureWeekdaysStackView()
        configureButtonActions()

        let titleLabels = [
            nameTitleLabel,
            detailTitleLabel,
            repeatTitleLabel,
            startTimeTitleLabel]
        let infoButtons = [detailInfoButton, repeatInfoButton]
        let repeatButtons = [repeatDailyButton, repeatWeekButton]
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))

        view.addGestureRecognizer(tapGesture)
        view.backgroundColor = .white
        tapGesture.cancelsTouchesInView = false

        titleLabels.forEach {
            $0.textColor = .black
            $0.font = BitnagilFont.init(style: .body1, weight: .semiBold).font
        }

        nameAsterisk.image = BitnagilIcon.asteriskIcon
        startTimeAsterisk.image = BitnagilIcon.asteriskIcon
        nameAsterisk.contentMode = .scaleAspectFit
        startTimeAsterisk.contentMode = .scaleAspectFit

        infoButtons.forEach {
            $0.setImage(BitnagilIcon.informationIcon, for: .normal)
        }

        repeatButtons.forEach {
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = 12
            $0.titleLabel?.font = BitnagilFont.init(style: .body2, weight: .semiBold).font
        }

        nameTitleLabel.text = "루틴 이름"
        detailTitleLabel.text = "세부 루틴"
        repeatTitleLabel.text = "루틴 반복"
        startTimeTitleLabel.text = "시작 시간"

        nameInputView.delegate = self
        nameInputView.configure(
            canDelete: false,
            placeholder: "ex) \(RoutineCreationViewModel.RoutineExample.wakeUp.rawValue)")

        allDayButton.setImage(BitnagilIcon.uncheckedIcon, for: .normal)

        detailWarningLabel.text = "* 세부 루틴은 최대 3개까지 입력이 가능해요"
        detailWarningLabel.textColor = BitnagilColor.error
        detailWarningLabel.font = BitnagilFont(style: .caption1, weight: .medium).font

        detailToolTipView.configure(message: "어려운 루틴이라면 단계별로 나눠보세요!")
        repeatToolTipView.configure(message: "선택하지 않을 경우, 당일 루틴으로만 자동 설정돼요.")
        detailToolTipView.isHidden = true
        repeatToolTipView.isHidden = true

        repeatDailyButton.setTitle("매일", for: .normal)
        repeatWeekButton.setTitle("요일 선택", for: .normal)

        allDayLabel.text = "하루 종일"
        allDayLabel.textColor = BitnagilColor.navy400
        allDayLabel.font = BitnagilFont.init(style: .body2, weight: .medium).font

        registerButton.backgroundColor = BitnagilColor.navy50
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.setTitleColor(BitnagilColor.gray70, for: .disabled)

        registerButton.layer.cornerRadius = 12
        registerButton.layer.masksToBounds = true
        registerButton.setTitle(registerButtonTitle, for: .normal)
        registerButton.isEnabled = false
        registerButton.titleLabel?.font = BitnagilFont.init(style: .body1, weight: .semiBold).font
    }

    override func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(nameTitleLabel)
        contentView.addSubview(nameAsterisk)
        contentView.addSubview(nameInputView)

        contentView.addSubview(detailTitleLabel)
        contentView.addSubview(detailInfoButton)
        contentView.addSubview(detailToolTipView)
        contentView.addSubview(subroutineAdditionButton)
        contentView.addSubview(subroutineStackView)
        contentView.addSubview(detailWarningLabel)

        contentView.addSubview(repeatTitleLabel)
        contentView.addSubview(repeatToolTipView)
        contentView.addSubview(repeatInfoButton)
        contentView.addSubview(repeatDailyButton)
        contentView.addSubview(repeatWeekButton)
        contentView.addSubview(weekdaysStackView)

        contentView.addSubview(startTimeTitleLabel)
        contentView.addSubview(startTimeAsterisk)
        contentView.addSubview(allDayButton)
        contentView.addSubview(allDayLabelButton)
        contentView.addSubview(allDayLabel)
        contentView.addSubview(timePickerButton)

        contentView.addSubview(registerButton)

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(safeArea)
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
            make.height.equalTo(scrollView.frameLayoutGuide).priority(.low)
        }

        nameTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Layout.nameTitleLabelTopSpacing)
            make.leading.equalToSuperview().offset(Layout.horizontalInset)
            make.height.equalTo(Layout.titleLabelHeight)
        }

        nameAsterisk.snp.makeConstraints { make in
            make.top.equalTo(nameTitleLabel).offset(-Layout.titleAsteriskTopSpacing)
            make.leading.equalTo(nameTitleLabel.snp.trailing).offset(Layout.titleAsteriskLeadingSpacing)
            make.height.equalTo(Layout.titleAsteriskHeight)
            make.width.equalTo(Layout.titleAsteriskWidth)
        }

        nameInputView.snp.makeConstraints { make in
            make.top.equalTo(nameTitleLabel.snp.bottom).offset(Layout.titleLabelBottomSpacing)
            make.horizontalEdges.equalToSuperview().inset(Layout.horizontalInset)
            make.height.equalTo(Layout.inputViewHeight)
        }

        detailTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(nameInputView.snp.bottom).offset(Layout.titleLabelTopSpacing)
            make.leading.equalToSuperview().offset(Layout.horizontalInset)
            make.height.equalTo(Layout.titleLabelHeight)
        }

        detailInfoButton.snp.makeConstraints { make in
            make.leading.equalTo(detailTitleLabel.snp.trailing).offset(Layout.infoButtonLeadingSpacing)
            make.size.equalTo(Layout.infoButtonSize)
            make.centerY.equalTo(detailTitleLabel)
        }

        detailToolTipView.snp.makeConstraints { make in
            make.leading.equalTo(detailInfoButton.snp.centerX).offset(-Layout.tooltipViewLeadingSpacing)
            make.bottom.equalTo(detailInfoButton.snp.top).offset(-Layout.tooltipViewBottomSpacing)
            make.width.equalTo(Layout.detailTooltipWidth)
            make.height.equalTo(Layout.tooltipViewHeight)
        }

        subroutineAdditionButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(Layout.horizontalInset)
            make.top.equalTo(detailTitleLabel.snp.bottom).offset(Layout.titleLabelBottomSpacing)
            make.height.equalTo(Layout.inputViewHeight)
        }

        subroutineStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(Layout.horizontalInset)
            make.top.equalTo(subroutineAdditionButton.snp.bottom).offset(Layout.subroutineStackViewSpacing)
            make.height.equalTo(Layout.subroutineStackViewHeight).priority(.medium)
        }

        detailWarningLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(Layout.horizontalInset)
            make.top.equalTo(subroutineStackView.snp.bottom).offset(Layout.warningLabelTopSpacing)
            make.height.equalTo(Layout.warningLabelHeight)
        }

        repeatTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Layout.horizontalInset)
            make.height.equalTo(Layout.titleLabelHeight)
            repeatRoutineTitleTopConstraint =  make.top
                .equalTo(subroutineStackView.snp.bottom)
                .offset(Layout.titleLabelTopSpacing)
                .constraint
        }

        repeatInfoButton.snp.makeConstraints { make in
            make.leading.equalTo(repeatTitleLabel.snp.trailing).offset(Layout.infoButtonLeadingSpacing)
            make.size.equalTo(Layout.infoButtonSize)
            make.centerY.equalTo(repeatTitleLabel)
        }

        repeatToolTipView.snp.makeConstraints { make in
            make.leading.equalTo(repeatInfoButton.snp.centerX).offset(-Layout.tooltipViewLeadingSpacing)
            make.bottom.equalTo(repeatInfoButton.snp.top).offset(-Layout.tooltipViewBottomSpacing)
            make.width.equalTo(Layout.repeatTooltipWidth)
            make.height.equalTo(Layout.tooltipViewHeight)
        }

        repeatDailyButton.snp.makeConstraints { make in
            make.top.equalTo(repeatTitleLabel.snp.bottom).offset(Layout.titleLabelBottomSpacing)
            make.leading.equalToSuperview().offset(Layout.horizontalInset)
            make.height.equalTo(Layout.repeatButtonHeight)
        }

        repeatWeekButton.snp.makeConstraints { make in
            make.top.equalTo(repeatTitleLabel.snp.bottom).offset(Layout.titleLabelBottomSpacing)
            make.leading.equalTo(repeatDailyButton.snp.trailing).offset(Layout.repeatWeekDayButtonLeadingSpacing)
            make.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.height.equalTo(Layout.repeatButtonHeight)
            make.width.equalTo(repeatDailyButton)
        }

        weekdaysStackView.snp.makeConstraints { make in
            make.top.equalTo(repeatDailyButton.snp.bottom).offset(Layout.weekDayStackViewTopSpacing)
            make.horizontalEdges.equalToSuperview().inset(Layout.horizontalInset)
            make.height.equalTo(Layout.weekDayStackViewHeight)
        }

        startTimeTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Layout.horizontalInset)
            make.height.equalTo(Layout.titleLabelHeight)
            startTimeTitleTopConstraint = make.top
                .equalTo(repeatDailyButton.snp.bottom)
                .offset(Layout.titleLabelTopSpacing)
                .constraint
        }

        startTimeAsterisk.snp.makeConstraints { make in
            make.top.equalTo(startTimeTitleLabel).offset(-Layout.titleAsteriskTopSpacing)
            make.leading.equalTo(startTimeTitleLabel.snp.trailing).offset(Layout.titleAsteriskLeadingSpacing)
            make.height.equalTo(Layout.titleAsteriskHeight)
            make.width.equalTo(Layout.titleAsteriskWidth)
        }

        allDayLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.width.equalTo(Layout.allDayLabelWidth)
            make.centerY.equalTo(startTimeTitleLabel)
        }

        allDayButton.snp.makeConstraints { make in
            make.trailing.equalTo(allDayLabel.snp.leading).offset(-Layout.allDayButtonTrailingSpacing)
            make.size.equalTo(Layout.allDayButtonSize)
            make.centerY.equalTo(startTimeTitleLabel)
        }

        allDayLabelButton.snp.makeConstraints { make in
            make.edges.equalTo(allDayLabel)
        }

        timePickerButton.snp.makeConstraints { make in
            make.top.equalTo(startTimeTitleLabel.snp.bottom).offset(Layout.titleLabelBottomSpacing)
            make.horizontalEdges.equalToSuperview().inset(Layout.horizontalInset)
            make.height.equalTo(Layout.inputViewHeight)
        }

        registerButton.snp.makeConstraints { make in
            make.top.equalTo(timePickerButton.snp.bottom).offset(Layout.registerButtonTopSpacing)
            make.horizontalEdges.equalToSuperview().inset(Layout.horizontalInset)
            make.height.equalTo(Layout.registerButtonHeight)
            make.bottom.equalToSuperview().inset(Layout.registerButtonBottomSpacing)
        }
    }

    override func bind() {
        viewModel.output.namePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in
                self?.nameInputView.configure(title: name ?? "")
            }
            .store(in: &cancellables)

        viewModel.output.subRoutinesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] routines in
                var repeatRoutineTitleLabelTopSpacing = Layout.titleLabelTopSpacing

                self?
                    .subroutineStackView
                    .subviews
                    .enumerated()
                    .forEach {
                        guard let inputView = $0.element as? RoutineCreationInputView else { return }

                        if $0.offset < routines.count {
                            inputView.configure(title: routines[$0.offset])
                            inputView.isHidden = false
                        } else {
                            inputView.isHidden = true
                        }
                    }

                self?.detailWarningLabel.isHidden = routines.count < 3
                if !(self?.detailWarningLabel.isHidden ?? true) {
                    repeatRoutineTitleLabelTopSpacing += (Layout.warningLabelHeight + Layout.warningLabelTopSpacing)
                    self?.repeatRoutineTitleTopConstraint?.update(offset: repeatRoutineTitleLabelTopSpacing)
                }
            }
            .store(in: &cancellables)

        viewModel.output.repeatTypePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] repeatType in
                var startTimeLabelTopSpacing = Layout.titleLabelTopSpacing

                switch repeatType {
                case .none:
                    self?.repeatDailyButton.isSelected = false
                    self?.repeatWeekButton.isSelected = false
                    self?.weekdaysStackView.isHidden = true
                case .daily:
                    self?.repeatDailyButton.isSelected = true
                    self?.repeatWeekButton.isSelected = false
                    self?.weekdaysStackView.isHidden = true
                case .week:
                    self?.repeatDailyButton.isSelected = false
                    self?.repeatWeekButton.isSelected = true
                    self?.weekdaysStackView.isHidden = false
                    startTimeLabelTopSpacing += (Layout.weekDayStackViewHeight + Layout.weekDayStackViewTopSpacing)
                }

                self?.startTimeTitleTopConstraint?.update(offset: startTimeLabelTopSpacing)
                self?.configureRepeatButton()
            }
            .store(in: &cancellables)

        viewModel.output.weekDayPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] weekDays in
                let weekDaysIndex = weekDays.map { $0.id }

                self?.weekdaysStackView
                    .subviews
                    .enumerated()
                    .forEach {
                        let isContains = weekDaysIndex.contains($0.offset)
                        $0.element.backgroundColor = isContains
                            ? BitnagilColor.lightBlue100
                            : .white
                    }
            })
            .store(in: &cancellables)

        viewModel.output.executionTimePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] executionType in
                self?.timePickerButton.configure(title: executionType.description)
                let allDayButtonImage = executionType == "하루종일"
                    ? BitnagilIcon.checkedIcon
                    : BitnagilIcon.uncheckedIcon
                self?.allDayButton.setImage(allDayButtonImage, for: .normal)
            }
            .store(in: &cancellables)

        viewModel.output.isRoutineValid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isRegisterButtonEnabled in
                self?.registerButton.isEnabled = isRegisterButtonEnabled
                self?.registerButton.backgroundColor = isRegisterButtonEnabled
                    ? BitnagilColor.navy500
                    : BitnagilColor.navy50
            }
            .store(in: &cancellables)
    }

    private func configureButtonActions() {
        subroutineAdditionButton.addAction(
            UIAction { [weak self] _ in
                self?.viewModel.action(input: .addSubRoutine)
            },
            for: .touchUpInside)

        detailInfoButton.addAction(
            UIAction { [weak self] _ in
                self?.detailInfoButton.isSelected.toggle()
                if self?.detailInfoButton.isSelected ?? false {
                    self?.detailToolTipView.showTooltip()
                } else {
                    self?.detailToolTipView.hideTooltip()
                }
            },
            for: .touchUpInside)

        repeatInfoButton.addAction(
            UIAction { [weak self] _ in
                self?.repeatInfoButton.isSelected.toggle()
                if self?.repeatInfoButton.isSelected ?? false {
                    self?.repeatToolTipView.showTooltip()
                } else {
                    self?.repeatToolTipView.hideTooltip()
                }
            },
            for: .touchUpInside)

        repeatDailyButton.addAction(
            UIAction { [weak self] _ in
                self?.viewModel.action(input: .configureRepeatType(type: .daily))
            },
            for: .touchUpInside)

        repeatWeekButton.addAction(
            UIAction { [weak self] _ in
                self?.viewModel.action(input: .configureRepeatType(type: .week))
            },
            for: .touchUpInside)

        [allDayButton, allDayLabelButton].forEach {
            $0.addAction(
                UIAction { [weak self] _ in
                    self?.viewModel.action(input: .configureExecution(type: .allDay))
                },
                for: .touchUpInside)
        }

        timePickerButton.addAction(
            UIAction { [weak self] _ in
                let datePickerView = DatePickerView()
                datePickerView.delegate = self
                self?.presentCustomBottomSheet(contentViewController: datePickerView, maxHeight: Layout.datePickerBottomSheetHeight)
            },
            for: .touchUpInside)

        registerButton.addAction(
            UIAction { [weak self] _ in
                self?.viewModel.action(input: .registerRoutine)
                self?.navigationController?.popViewController(animated: true)
            },
            for: .touchUpInside)
    }

    private func configureSubroutineStackView() {
        subroutineStackView.axis = .vertical
        subroutineStackView.spacing = Layout.subroutineStackViewSpacing

        RoutineCreationViewModel.RoutineExample
            .allCases
            .dropFirst()
            .enumerated()
            .forEach {
                let view = RoutineCreationInputView()
                let placeholder = "\($0.offset + 1). ex) \($0.element.rawValue)"
                view.delegate = self
                view.configure(canDelete: true, placeholder: placeholder)
                view.snp.makeConstraints { make in
                    make.height.equalTo(Layout.inputViewHeight)
                }
                subroutineStackView.addArrangedSubview(view)
            }
    }

    private func configureWeekdaysStackView() {
        weekdaysStackView.isHidden = true
        weekdaysStackView.axis = .horizontal
        weekdaysStackView.spacing = Layout.weekDayStackViewSpacing
        weekdaysStackView.distribution = .fillEqually

        Week.allCases.forEach { week in
            let button = UIButton()
            button.setTitle(week.koreanValue, for: .normal)
            button.layer.cornerRadius = 12
            button.backgroundColor = .white
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = BitnagilFont.init(style: .body2, weight: .medium).font
            button.addAction(
                UIAction { [weak self] _ in
                    self?.viewModel.action(input: .toggleRepeatDay(weekDay: week))
                },
                for: .touchUpInside)
            weekdaysStackView.addArrangedSubview(button)
        }
    }

    private func configureRepeatButton() {
        [repeatDailyButton, repeatWeekButton].forEach {
            let isSelected = $0.isSelected
            let titleColor = isSelected
                ? BitnagilColor.navy500
                : BitnagilColor.navy100
            let borderColor = isSelected
                ? BitnagilColor.navy500?.cgColor
                : BitnagilColor.navy100?.cgColor

            $0.setTitleColor(titleColor, for: .normal)
            $0.layer.borderColor = borderColor
        }
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: contentView)

        // 탭한 곳이 버튼 영역인 경우
        if detailInfoButton.frame.contains(location) {
            repeatInfoButton.isSelected = false
            repeatToolTipView.hideTooltip()
            return
        }
        if repeatInfoButton.frame.contains(location) {
            detailInfoButton.isSelected = false
            detailToolTipView.hideTooltip()
            return
        }
        
        // 탭한 곳이 tooltip 영역 밖인 경우
        if !detailToolTipView.frame.contains(location) {
            detailInfoButton.isSelected = false
            detailToolTipView.hideTooltip()
        }
        if !repeatToolTipView.frame.contains(location) {
            repeatInfoButton.isSelected = false
            repeatToolTipView.hideTooltip()
        }

        view.endEditing(true)
    }
}

extension RoutineCreationView: RoutineCreationInputViewDelegate {
    func routineCreationInputViewDidTapDeleteButton(_ sender: RoutineCreationInputView) {
        guard let index = subroutineStackView.subviews.firstIndex(of: sender) else { return }

        viewModel.action(input: .deleteSubRoutine(index: index))
    }
    
    func routineCreationInputView(_ sender: RoutineCreationInputView, didChangeText text: String) {
        if sender === nameInputView {
            viewModel.action(input: .configureName(name: text))
            return
        }

        guard let index = subroutineStackView.subviews.firstIndex(of: sender) else { return }

        viewModel.action(input: .configureSubRoutine(name: text, index: index))
    }
}

extension RoutineCreationView: DatePickerViewDelegate {
    func datePickerView(_ pickerView: DatePickerView, didSelectTime time: Date) {
        viewModel.action(input: .configureExecution(type: .time(startAt: time)))
    }
}
