//
//  RoutineListViewController.swift
//  Presentation
//
//  Created by 최정인 on 8/18/25.
//

import Combine
import Shared
import SnapKit
import UIKit

final class RoutineListViewController: BaseViewController<RoutineListViewModel> {
    private enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let weekViewTopSpacing: CGFloat = 58
        static let weekViewHeight: CGFloat = 92
        static let emptyViewCenterYSpacing: CGFloat = 40
        static let emptyViewHeight: CGFloat = 102
        static let routineScrollViewTopSpacing: CGFloat = 16
        static let routineStackViewSpacing: CGFloat = 12
        static let routineStackViewBottomSpacing: CGFloat = 60
    }

    private let weekView: WeekView
    private let emptyView = HomeEmptyView()
    private let routineScrollView = UIScrollView()
    private let routineStackView = UIStackView()
    private var routineCardViews: [String: RoutineCardView] = [:]
    private var cancellables: Set<AnyCancellable>

    init(viewModel: RoutineListViewModel, selectedDate: Date) {
        self.weekView = WeekView(date: selectedDate)
        cancellables = []
        super.init(viewModel: viewModel)
        viewModel.action(input: .selectDate(date: selectedDate))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.action(input: .fetchRoutineList)
    }

    override func configureAttribute() {
        weekView.delegate = self

        emptyView.isHidden = true
        emptyView.didTapRegisterRoutineButton = {
            guard let routineCreationViewModel = DIContainer.shared.resolve(type: RoutineCreationViewModel.self)
            else { fatalError("routineCreationViewModel 의존성이 등록되지 않았습니다.") }

            let routineCreationView = RoutineCreationViewController(viewModel: routineCreationViewModel)
            routineCreationView.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(routineCreationView, animated: true)
        }

        routineScrollView.showsVerticalScrollIndicator = false

        routineStackView.axis = .vertical
        routineStackView.spacing = Layout.routineStackViewSpacing
    }

    override func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        view.backgroundColor = BitnagilColor.gray99
        configureCustomNavigationBar(navigationBarStyle: .withBackButton(title: "루틴 리스트"), backgroundColor: BitnagilColor.gray99)

        view.addSubview(weekView)
        view.addSubview(emptyView)
        view.addSubview(routineScrollView)
        routineScrollView.addSubview(routineStackView)

        weekView.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(Layout.weekViewTopSpacing)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(Layout.weekViewHeight)
        }

        emptyView.snp.makeConstraints { make in
            make.centerX.equalTo(safeArea)
            make.centerY.equalTo(safeArea).offset(Layout.emptyViewCenterYSpacing)
            make.height.equalTo(Layout.emptyViewHeight)
        }

        routineScrollView.snp.makeConstraints { make in
            make.top.equalTo(weekView.snp.bottom).offset(Layout.routineScrollViewTopSpacing)
            make.bottom.equalTo(safeArea)
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.trailing.equalTo(safeArea).inset(Layout.horizontalMargin)
        }

        routineStackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(Layout.routineStackViewBottomSpacing)
            make.width.equalTo(routineScrollView.snp.width)
        }
    }

    override func bind() {
        viewModel.output.selectedDatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedDate in
                self?.weekView.updateWeekDateViews(date: selectedDate)
            }
            .store(in: &cancellables)

        viewModel.output.routinesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] routines in
                self?.updateRoutineStackView(routines: routines)
            }
            .store(in: &cancellables)
    }

    private func updateRoutineStackView(routines: [newRoutine]) {
        routineStackView.arrangedSubviews.forEach { view in
            routineStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        routineCardViews.removeAll()

        emptyView.isHidden = !routines.isEmpty
        routineScrollView.isHidden = routines.isEmpty
        for routine in routines {
            let routineCardView = RoutineCardView(routine: routine)
            routineCardViews[routine.id] = routineCardView
            routineStackView.addArrangedSubview(routineCardView)
        }
    }
}

extension RoutineListViewController: WeekViewDelegate {
    func weekView(_ sender: WeekView, didSelectDate date: Date) {
        viewModel.action(input: .selectDate(date: date))
    }
}
