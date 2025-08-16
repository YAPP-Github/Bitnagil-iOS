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
    private enum Layout {
        static let horizontalSpacing: CGFloat = 20
        static let textFieldHeight: CGFloat = 24
        static let textFieldTopSpacing: CGFloat = 51
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
    private let routineTextField = UITextField()
    private let textViewUnderLineView = UIView()
    private let clearButton = UIButton()
    
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
        configureCustomNavigationBar(navigationBarStyle: .withBackButton(title: navigationTitle))
    }

    override func configureAttribute() {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: BitnagilFont(style: .title3, weight: .semiBold).font,
            .foregroundColor: BitnagilColor.gray90 ?? .systemGray]

        view.backgroundColor = .white

        routineTextField.attributedPlaceholder = NSAttributedString(string: "루틴 제목을 입력해주세요.", attributes: attributes)
        routineTextField.font = BitnagilFont(style: .title3, weight: .semiBold).font
        routineTextField.textColor = BitnagilColor.gray10

        textViewUnderLineView.backgroundColor = BitnagilColor.gray90

        clearButton.setImage(BitnagilIcon.clearIcon, for: .normal)

        registerButton.layer.cornerRadius = 12
        registerButton.layer.masksToBounds = true
        registerButton.titleLabel?.font = BitnagilFont.init(style: .body1, weight: .semiBold).font
        registerButton.backgroundColor = BitnagilColor.gray95
        registerButton.setTitle("등록하기", for: .normal)

        subRoutineNameView.configure(dependencies: .init(subRoutines: ["ㄴㄴㄴ", "ㅋㅋㅋ"]))
        bindCreationCardViews()
    }

    override func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        navigationController?.setNavigationBarHidden(true, animated: false)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(routineTextField)
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

        routineTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Layout.textFieldTopSpacing)
            make.horizontalEdges.equalToSuperview().inset(Layout.horizontalSpacing)
            make.height.equalTo(Layout.textFieldHeight)
        }

        clearButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-Layout.horizontalSpacing)
            make.centerY.equalTo(routineTextField)
            make.size.equalTo(Layout.clearButtonSize)
        }

        textViewUnderLineView.snp.makeConstraints { make in
            make.top.equalTo(routineTextField.snp.bottom).offset(Layout.textFieldUnderLineTopSpacing)
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

    }

    private func bindCreationCardViews() {
        periodView.onAction = { [weak self] action in
            let datePickerView = BitnagilCalendarView()
            datePickerView.delegate = self

            self?.presentCustomBottomSheet(contentViewController: datePickerView, maxHeight: Layout.calendarBottomSheetHeight)
        }

        timeView.onAction = { [weak self] action in
            switch action {
            case .allDayTapped:
                print()
            case .timeSetTapped:
                let datePickerView = TimePickerView()
                datePickerView.delegate = self
                self?.presentCustomBottomSheet(contentViewController: datePickerView, maxHeight: Layout.timePickerBottomSheetHeight)
            }
        }
    }
}

extension RoutineCreationViewController: TimePickerViewDelegate {
    func timePickerView(_ pickerView: TimePickerView, didSelectTime time: Date) {
        viewModel.action(input: .configureExecution(type: .time(startAt: time)))
        timeView.configure(dependencies: .init(startTime: time))
    }
}

extension RoutineCreationViewController: BitnagilCalendarViewDelegate {
    func bitnagilCalendarView(_ sender: BitnagilCalendarView, didSelectDate date: Date) {
        periodView.configure(dependencies: .init(start: date, end: date))
    }
}
