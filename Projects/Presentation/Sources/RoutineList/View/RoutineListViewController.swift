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
    private var dimmedView: UIView?
    private var cancellables: Set<AnyCancellable>

    init(viewModel: RoutineListViewModel, selectedDate: Date) {
        self.weekView = WeekView(date: selectedDate)
        cancellables = []
        viewModel.action(input: .selectDate(date: selectedDate))
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.action(input: .fetchRoutineList)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.subviews.first(where: { $0.tag == 999 })?.removeFromSuperview()
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
        viewModel.output.fetchRoutinesResultPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isFetchRoutines in
                if isFetchRoutines {
                    self?.viewModel.action(input: .fetchDailyRoutine)
                }
            }
            .store(in: &cancellables)

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

    private func updateRoutineStackView(routines: [Routine]) {
        routineStackView.arrangedSubviews.forEach { view in
            routineStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        routineCardViews.removeAll()

        emptyView.isHidden = !routines.isEmpty
        routineScrollView.isHidden = routines.isEmpty
        for routine in routines {
            let routineCardView = RoutineCardView(routine: routine)
            routineCardView.delegate = self
            routineCardViews[routine.id] = routineCardView
            routineStackView.addArrangedSubview(routineCardView)
        }
    }

    private func goToRoutineCreationView(routineId: String, isApplyToday: Bool = true) {
        guard let routineCreationViewModel = DIContainer.shared.resolve(type: RoutineCreationViewModel.self)
        else { fatalError("routineCreationViewModel 의존성이 등록되지 않았습니다.") }

        let routineCreationView = RoutineCreationViewController(
            viewModel: routineCreationViewModel,
            updateInfo: (routineId, isApplyToday ? .today : .tomorrow))
        routineCreationView.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(routineCreationView, animated: true)
    }
}

// MARK: WeekViewDelegate
extension RoutineListViewController: WeekViewDelegate {
    func weekView(_ sender: WeekView, didSelectDate date: Date) {
        viewModel.action(input: .selectDate(date: date))
    }
}

// MARK: RoutineCardViewDelegate
extension RoutineListViewController: RoutineCardViewDelegate {
    func routineCardView(_ sender: RoutineCardView, didTapPlusButton routine: RecommendedRoutine) { }

    func routineCardView(_ sender: RoutineCardView, didTapEditButton routine: Routine) {
        viewModel.action(input: .selectRoutine(routine: routine))

        guard !routine.repeatDay.isEmpty else {
            goToRoutineCreationView(routineId: routine.id)
            return
        }

        dimmedView?.removeFromSuperview()

        let newDimmedView = UIView()
        newDimmedView.backgroundColor = .black.withAlphaComponent(0.7)
        newDimmedView.frame = view.bounds
        view.addSubview(newDimmedView)
        dimmedView = newDimmedView

        let routineEditAlertViewController = RoutineEditAlertViewController()
        if let sheet = routineEditAlertViewController.sheetPresentationController {
            sheet.prefersGrabberVisible = false
            if #available(iOS 16.0, *) {
                sheet.detents = [.custom { _ in 250 }]
            } else {
                sheet.detents = [.medium()]
            }
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.preferredCornerRadius = 20
        }

        routineEditAlertViewController.onDismiss = { [weak self] in
            self?.dimmedView?.removeFromSuperview()
            self?.dimmedView = nil
        }

        routineEditAlertViewController.goToRoutineCreationView = { [weak self] isApplyToday in
            self?.goToRoutineCreationView(routineId: routine.id, isApplyToday: isApplyToday)
        }

        present(routineEditAlertViewController, animated: true)
    }
    
    func routineCardView(_ sender: RoutineCardView, didTapDeleteButton routine: Routine) {
        viewModel.action(input: .selectRoutine(routine: routine))

        dimmedView?.removeFromSuperview()

        let newDimmedView = UIView()
        newDimmedView.backgroundColor = .black.withAlphaComponent(0.7)
        newDimmedView.frame = view.bounds
        view.addSubview(newDimmedView)
        dimmedView = newDimmedView

        if routine.repeatDay.isEmpty {
            let routineDeleteAlertViewController = RoutineDeleteAlertViewController(viewModel: viewModel, isDeleteAllRoutines: false)
            if let sheet = routineDeleteAlertViewController.sheetPresentationController {
                sheet.prefersGrabberVisible = false
                if #available(iOS 16.0, *) {
                    sheet.detents = [.custom { _ in 204 }]
                } else {
                    sheet.detents = [.medium()]
                }
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.preferredCornerRadius = 20
            }

            routineDeleteAlertViewController.onDismiss = { [weak self] in
                self?.dimmedView?.removeFromSuperview()
                self?.dimmedView = nil
            }

            present(routineDeleteAlertViewController, animated: true)
        } else {
            let routineDeleteViewController = RoutineDeleteViewController(viewModel: viewModel)
            if let sheet = routineDeleteViewController.sheetPresentationController {
                sheet.prefersGrabberVisible = false
                if #available(iOS 16.0, *) {
                    sheet.detents = [.custom { _ in 270 }]
                } else {
                    sheet.detents = [.medium()]
                }
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.preferredCornerRadius = 20
            }

            routineDeleteViewController.onDismiss = { [weak self] in
                self?.dimmedView?.removeFromSuperview()
                self?.dimmedView = nil
            }

            present(routineDeleteViewController, animated: true)
        }
    }
}
