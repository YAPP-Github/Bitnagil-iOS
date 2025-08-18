//
//  RoutineCreationViewController.swift
//  Presentation
//
//  Created by 이동현 on 8/15/25.
//

import Combine
import Domain
import SnapKit
import UIKit

final class RoutineCreationViewController: BaseViewController<RoutineCreationViewModel> {
    private enum DateSelectionType {
        case start
        case end
    }

    private enum Layout {
        static let horizontalSpacing: CGFloat = 20
        static let textFieldHeight: CGFloat = 24
        static let textFieldTopSpacing: CGFloat = 90
        static let textFieldUnderLineTopSpacing: CGFloat = 12
        static let textFieldUnderLineHeight: CGFloat = 2
        static let clearButtonSize: CGFloat = 16
        static let subroutineViewTopSpacing: CGFloat = 40
        static let routineCreationViewTopSpacing: CGFloat = 12
        static let registerButtonTopSpacing: CGFloat = 59
        static let registerButtonHeight: CGFloat = 54
        static let registerButtonBottomSpacing: CGFloat = 14
        static let timePickerBottomSheetHeight: CGFloat = 357
        static let calendarBottomSheetHeight: CGFloat = 517
    }

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let nameTextField = UITextField()
    private let textViewUnderLineView = UIView()
    private let clearButton = UIButton()
    private var dateSelectionType: DateSelectionType?

    private let subRoutineNameView = RoutineCreationCardView<RoutineNameContentView>(
        title: "세부루틴",
        placeHolder: "ex) 일어나자마자 이불 개기",
        titleImage: BitnagilIcon.routineListIcon,
        withInfoImage: true,
        withAsteriskImage: false)
    private let repeatView = RoutineCreationCardView<RoutineRepeatContentView>(
        title: "반복 요일",
        placeHolder: "ex) 매주 월,화,수,목,금",
        titleImage: BitnagilIcon.routineRepeatIcon,
        withInfoImage: false,
        withAsteriskImage: false)
    private let periodView = RoutineCreationCardView<RoutinePeriodContentView>(
        title: "목표 기간",
        placeHolder: "ex) 25.08.06 - 25.08.06",
        titleImage: BitnagilIcon.routineDateIcon,
        withInfoImage: false,
        withAsteriskImage: true)
    private let timeView = RoutineCreationCardView<RoutineTimeContentView>(
        title: "시간",
        placeHolder: "ex) 오전 9:40부터 시작",
        titleImage: BitnagilIcon.routineTimeIcon,
        withInfoImage: false,
        withAsteriskImage: true)

    private let registerButton = UIButton()
    private let navigationTitle: String
    private let registerButtonTitle: String
    private var cancellables = Set<AnyCancellable>()

    init(
        viewModel: RoutineCreationViewModel,
        updateInfo: (routineId: String, updateType: RoutineUpdateApplyDateType)? = nil
    ) {
        navigationTitle = updateInfo?.routineId == nil ? "루틴 등록" : "루틴 수정"
        registerButtonTitle = updateInfo?.routineId == nil ? "등록하기" : "수정하기"

        super.init(viewModel: viewModel)

        registerButton.setTitle(registerButtonTitle, for: .normal)
        if let updateInfo {
            viewModel.action(input: .fetchRoutine(id: updateInfo.routineId))
            viewModel.action(input: .configureUpdateType(updateType: updateInfo.updateType))
        }
    }

    init(viewModel: RoutineCreationViewModel, recommendRoutineId: Int) {
        navigationTitle = "루틴 등록"
        registerButtonTitle = "등록하기"

        super.init(viewModel: viewModel)

        registerButton.setTitle(registerButtonTitle, for: .normal)
        viewModel.action(input: .fetchRecommendedRoutine(id: recommendRoutineId))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureCustomNavigationBar(navigationBarStyle: .withBackButton(title: navigationTitle))
    }

    override func configureAttribute() {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: BitnagilFont(style: .title3, weight: .semiBold).font,
            .foregroundColor: BitnagilColor.gray90 ?? .systemGray]

        view.backgroundColor = .white

        nameTextField.attributedPlaceholder = NSAttributedString(string: "루틴 제목을 입력해주세요.", attributes: attributes)
        nameTextField.font = BitnagilFont(style: .title3, weight: .semiBold).font
        nameTextField.textColor = BitnagilColor.gray10
        nameTextField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        nameTextField.delegate = self
        textViewUnderLineView.backgroundColor = BitnagilColor.gray90

        clearButton.setImage(BitnagilIcon.clearIcon, for: .normal)
        clearButton.addAction(
            UIAction { [weak self] _ in
                self?.nameTextField.text = ""
                self?.viewModel.action(input: .configureName(name: ""))
            },
            for: .touchUpInside)

        registerButton.layer.cornerRadius = 12
        registerButton.layer.masksToBounds = true
        registerButton.titleLabel?.font = BitnagilFont.init(style: .body1, weight: .semiBold).font
        registerButton.addAction(
            UIAction { [weak self] _ in
                self?.viewModel.action(input: .registerRoutine)
            },
            for: .touchUpInside)
        bindCreationCardViews()
    }

    override func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        navigationController?.setNavigationBarHidden(true, animated: false)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(nameTextField)
        contentView.addSubview(clearButton)
        contentView.addSubview(textViewUnderLineView)
        contentView.addSubview(subRoutineNameView)
        contentView.addSubview(repeatView)
        contentView.addSubview(periodView)
        contentView.addSubview(timeView)
        contentView.addSubview(registerButton)

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(safeArea)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
            make.height.equalTo(scrollView.frameLayoutGuide).priority(.low)
        }

        nameTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Layout.textFieldTopSpacing)
            make.horizontalEdges.equalToSuperview().inset(Layout.horizontalSpacing)
            make.height.equalTo(Layout.textFieldHeight)
        }

        clearButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-Layout.horizontalSpacing)
            make.centerY.equalTo(nameTextField)
            make.size.equalTo(Layout.clearButtonSize)
        }

        textViewUnderLineView.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(Layout.textFieldUnderLineTopSpacing)
            make.horizontalEdges.equalToSuperview().inset(Layout.horizontalSpacing)
            make.height.equalTo(Layout.textFieldUnderLineHeight)
        }

        subRoutineNameView.snp.makeConstraints { make in
            make.top.equalTo(textViewUnderLineView.snp.bottom).offset(Layout.subroutineViewTopSpacing)
            make.horizontalEdges.equalToSuperview().inset(Layout.horizontalSpacing)
        }

        repeatView.snp.makeConstraints { make in
            make.top.equalTo(subRoutineNameView.snp.bottom).offset(Layout.routineCreationViewTopSpacing)
            make.horizontalEdges.equalToSuperview().inset(Layout.horizontalSpacing)
        }

        periodView.snp.makeConstraints { make in
            make.top.equalTo(repeatView.snp.bottom).offset(Layout.routineCreationViewTopSpacing)
            make.horizontalEdges.equalToSuperview().inset(Layout.horizontalSpacing)
        }

        timeView.snp.makeConstraints { make in
            make.top.equalTo(periodView.snp.bottom).offset(Layout.routineCreationViewTopSpacing)
            make.horizontalEdges.equalToSuperview().inset(Layout.horizontalSpacing)
        }

        registerButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(timeView.snp.bottom).offset(Layout.registerButtonTopSpacing)
            make.horizontalEdges.equalToSuperview().inset(Layout.horizontalSpacing)
            make.height.equalTo(Layout.registerButtonHeight)
            make.bottom.equalToSuperview().inset(Layout.registerButtonBottomSpacing)
        }
    }

    override func bind() {
        viewModel.output.namePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in
                self?.nameTextField.text = name
            }
            .store(in: &cancellables)

        viewModel.output.subRoutinesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] subroutines in
                self?.subRoutineNameView.configure(dependency: .init(subRoutines: subroutines))
                self?.subRoutineNameView.configure(subTitles: subroutines.filter { !$0.isEmpty })
            }
            .store(in: &cancellables)

        viewModel.output.repeatTypePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] repeatType in
                guard let repeatType else {
                    self?.repeatView.configure(dependency: .init(repeatType: .none))
                    self?.repeatView.configure(subTitles: [])
                    return
                }

                switch repeatType {
                case .daily:
                    let subTitle = Week.allCases
                        .map { $0.koreanValue }
                        .joined(separator: ",")
                    self?.repeatView.configure(dependency: .init(repeatType: .daily))
                    self?.repeatView.configure(subTitles: ["매주 \(subTitle)"])
                case .weekly(let weeks):
                    let subTitle = weeks
                        .sorted(by: { $0.id < $1.id })
                        .map { $0.koreanValue }
                        .joined(separator: ",")
                    self?.repeatView.configure(dependency: .init(repeatType: .weekly(weeks: weeks)))
                    self?.repeatView.configure(subTitles: weeks.isEmpty ? [] : ["매주 \(subTitle)"])
                }
            }
            .store(in: &cancellables)

        viewModel.output.periodPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (start, end) in
                self?.periodView.configure(dependency: .init(dates: (start, end)))
            }
            .store(in: &cancellables)

        viewModel.output.executionTimePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] startAt in
                self?.timeView.configure(dependency: .init(startTime: startAt))

                if let startAt {
                    let timeString = startAt.isMidnight ? "하루 종일" : startAt.convertToString(dateType: .amPmTime)
                    self?.timeView.configure(subTitles: [timeString])
                } else {
                    self?.timeView.configure(subTitles: [])
                }
            }
            .store(in: &cancellables)

        viewModel.output.isRoutineValid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isRoutineValid in
                if isRoutineValid {
                    self?.registerButton.isEnabled = true
                    self?.registerButton.backgroundColor = BitnagilColor.gray10
                    self?.registerButton.setTitleColor(.white, for: .normal)
                } else {
                    self?.registerButton.isEnabled = false
                    self?.registerButton.backgroundColor = BitnagilColor.gray95
                    self?.registerButton.setTitleColor(.white, for: .normal)
                }
            }
            .store(in: &cancellables)
    }

    private func bindCreationCardViews() {
        subRoutineNameView.onAction = { [weak self] action in
            switch action {
            case .subroutineChanged(let index, let text):
                self?.viewModel.action(input: .configureSubRoutine(name: text, index: index))
            case .deleteAllSubroutines:
                self?.viewModel.action(input: .deleteAllSubRoutines)
            }
        }

        repeatView.onAction = { [weak self] action in
            switch action {
            case .repeatDaily:
                self?.viewModel.action(input: .configureRepeatType(type: .daily))
            case .repeatWeekly:
                self?.viewModel.action(input: .configureRepeatType(type: .weekly(weeks: [])))
            case .setWeeks(let weeks):
                self?.viewModel.action(input: .configureRepeatWeeks(weeks: weeks))
            }
        }

        periodView.onAction = { [weak self] action in
            switch action {
            case .startDateSetTapped:
                self?.dateSelectionType = .start
            case .endDateSetTapped:
                self?.dateSelectionType = .end
            }

            let datePickerView = BitnagilCalendarView()
            datePickerView.delegate = self

            self?.presentCustomBottomSheet(contentViewController: datePickerView, maxHeight: Layout.calendarBottomSheetHeight)
        }

        timeView.onAction = { [weak self] action in
            switch action {
            case .allDayTapped:
                self?.viewModel.action(input: .toggleAllDay)
            case .timeSetTapped:
                let datePickerView = TimePickerView()
                datePickerView.delegate = self
                self?.presentCustomBottomSheet(contentViewController: datePickerView, maxHeight: Layout.timePickerBottomSheetHeight)
            }
        }
    }

    @objc private func textFieldEditingChanged(_ sender: UITextField) {
        viewModel.action(input: .configureName(name: sender.text ?? ""))
    }
}

extension RoutineCreationViewController: TimePickerViewDelegate {
    func timePickerView(_ pickerView: TimePickerView, didSelectTime time: Date) {
        viewModel.action(input: .configureExecution(type: .init(startAt: time)))
    }
}

extension RoutineCreationViewController: BitnagilCalendarViewDelegate {
    func bitnagilCalendarView(_ sender: BitnagilCalendarView, didSelectDate date: Date) {
        guard let dateSelectionType else { return }

        switch dateSelectionType {
        case .start:
            viewModel.action(input: .configureStartDate(date: date))
        case .end:
            viewModel.action(input: .configureEndDate(date: date))
        }
        self.dateSelectionType = nil
    }
}


extension RoutineCreationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
