//
//  HomeView.swift
//  Presentation
//
//  Created by 최정인 on 6/15/25.
//

import Combine
import Kingfisher
import Shared
import SnapKit
import UIKit

final class HomeView: BaseViewController<HomeViewModel> {
    private enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let headerViewHeight: CGFloat = 48
        static let logoImageWidth: CGFloat = 71
        static let logoImageHeight: CGFloat = 22
        static let headerIconTrailingSpacing: CGFloat = 8
        static let homeLabelTopSpacing: CGFloat = 18
        static let homeLabelHeight: CGFloat = 60
        static let registerEmotionButtonTopSpacing: CGFloat = 16
        static let registerEmotionButtonHeight: CGFloat = 36
        static let registerEmotionButtonWidth: CGFloat = 136
        static let emotionOrbViewTopSpacing: CGFloat = 46
        static let emotionOrbViewTrailingSpacing: CGFloat = 35
        static let emotionOrbViewSize: CGFloat = 172
        static let contentViewCornerRadius: CGFloat = 20
        static let weekViewHeight: CGFloat = 92
        static let routineSortButtonTrailingSpacing: CGFloat = 8
        static let routineSortButtonSize: CGFloat = 40
        static let routineSortViewHeight: CGFloat = 192
        static let routineStackViewSpacing: CGFloat = 21
        static let routineStackViewTopSpacing: CGFloat = 23
        static let routineStackViewBottomSpacing: CGFloat = 100
        static let emptyViewTopSpacing: CGFloat = 77
        static let emptyViewHeight: CGFloat = 120
        static let collapsedTop: CGFloat = 225
        static let expandedTop: CGFloat = 48
        static let floatingButtonBottomSpacing: CGFloat = 19
        static let floatingButtonSize: CGFloat = 52
        static let floatingMenuBottomSpacing: CGFloat = 15
        static let floatingMenuHeight: CGFloat = 64
        static let floatingMenuWidth: CGFloat = 144
    }

    // headerView
    private let headerView = UIView()
    private let logoImageView = UIImageView()
    private let helpButton = UIButton()
    private let alarmButton = UIButton()

    // label + emotion
    private let homeLabel = UILabel()
    private let emotionOrbView = UIImageView()
    private let registerEmotionButton = HomeRegisterEmotionButton()

    // contentView
    private let contentView = UIView()

    // weekView
    private let weekStackView = UIStackView()
    private let weekHeaderView = UIView()
    private let monthLabel = UILabel()
    private let previousWeekButton = UIButton()
    private let nextWeekButton = UIButton()
    private let weekView = WeekView()

    // routineView
    private let emptyView = HomeEmptyView()
    private let routineScrollView = UIScrollView()
    private let routineStackView = UIStackView()
    private let loadingIndicatorView = UIActivityIndicatorView(style: .large)

    // floatingButton
    private var isShowingFloatingMenu: Bool = false
    private let dimmedView = UIView()
    private let floatingButton = FloatingButton()
    private let floatingMenu = FloatingMenuView()
    private var bottomSheet: CustomBottomSheet?

    private var contentViewTopConstraint: Constraint?
    private var cancellables: Set<AnyCancellable>

    override init(viewModel: HomeViewModel) {
        cancellables = []
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        showIndicatorView()
        viewModel.action(input: .loadNickname)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        viewModel.action(input: .loadEmotion)
        viewModel.action(input: .fetchRoutines)
    }

    override func configureAttribute() {
        logoImageView.image = BitnagilGraphic.grayLogoGraphic
        helpButton.setImage(BitnagilIcon.helpIcon, for: .normal)
        alarmButton.setImage(BitnagilIcon.alarmIcon, for: .normal)

        let homeLabelText = "님,\n오늘 기분 어때요?"
        homeLabel.attributedText = BitnagilFont(
            family: .cafe24Ssurround,
            style: .cafe24Title1,
            weight: .light).attributedString(text: homeLabelText)
        homeLabel.numberOfLines = 2
        homeLabel.textColor = .white

        registerEmotionButton.addAction(
            UIAction { [weak self] _ in
                self?.goToEmotionRegisterView()
            },
            for: .touchUpInside)

        contentView.backgroundColor = BitnagilColor.gray99
        contentView.layer.cornerRadius = Layout.contentViewCornerRadius
        contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentView.clipsToBounds = true

        weekStackView.axis = .vertical
        weekStackView.spacing = 4

        monthLabel.text = " "
        monthLabel.font = BitnagilFont(style: .title3, weight: .semiBold).font
        monthLabel.textColor = BitnagilColor.gray10

        previousWeekButton.setImage(BitnagilIcon.chevronLeftIcon, for: .normal)
        previousWeekButton.addAction(
            UIAction { [weak self] _ in
                self?.viewModel.action(input: .moveWeek(week: -1))
            }, for: .touchUpInside)

        nextWeekButton.setImage(BitnagilIcon.chevronRightIcon, for: .normal)
        nextWeekButton.addAction(
            UIAction { [weak self] _ in
                self?.viewModel.action(input: .moveWeek(week: 1))
            }, for: .touchUpInside)

        let panGesture = UIPanGestureRecognizer()
        panGesture.addTarget(self, action: #selector(handlePanGesture(_:)))
        weekStackView.addGestureRecognizer(panGesture)
        weekStackView.isUserInteractionEnabled = true
        weekView.delegate = self

        emptyView.didTapRegisterRoutineButton = {
            guard let routineCreationViewModel = DIContainer.shared.resolve(type: RoutineCreationViewModel.self)
            else { fatalError("routineCreationViewModel 의존성이 등록되지 않았습니다.") }

            let routineCreationView = RoutineCreationView(viewModel: routineCreationViewModel)
            routineCreationView.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(routineCreationView, animated: true)
        }

        routineScrollView.showsVerticalScrollIndicator = false
        routineScrollView.showsHorizontalScrollIndicator = false

        routineStackView.axis = .vertical
        routineStackView.spacing = Layout.routineStackViewSpacing
        routineStackView.alignment = .fill
        routineStackView.distribution = .fill

        floatingButton.addAction(UIAction { [weak self] _ in
            self?.toggleFloatingButton()
        }, for: .touchUpInside)

        floatingMenu.isHidden = true
        floatingMenu.delegate = self

        dimmedView.isHidden = true
        dimmedView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        dimmedView.alpha = 0

        let dimmedViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedDimmedView))
        dimmedView.addGestureRecognizer(dimmedViewTapGesture)

        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.color = BitnagilColor.gray40
    }

    override func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        view.backgroundColor = BitnagilColor.gray10
        navigationController?.setNavigationBarHidden(true, animated: false)

        [logoImageView, helpButton, alarmButton].forEach {
            headerView.addSubview($0)
        }
        view.addSubview(headerView)

        view.addSubview(homeLabel)
        view.addSubview(emotionOrbView)
        view.addSubview(registerEmotionButton)

        view.addSubview(contentView)
        [monthLabel, previousWeekButton, nextWeekButton].forEach {
            weekHeaderView.addSubview($0)
        }
        [weekHeaderView, weekView].forEach {
            weekStackView.addArrangedSubview($0)
        }
        contentView.addSubview(weekStackView)
        contentView.addSubview(emptyView)
        contentView.addSubview(routineScrollView)
        routineScrollView.addSubview(routineStackView)
        contentView.addSubview(loadingIndicatorView)

        view.addSubview(dimmedView)
        view.addSubview(floatingMenu)
        view.addSubview(floatingButton)

        headerView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeArea)
            make.height.equalTo(Layout.headerViewHeight)
        }

        logoImageView.snp.makeConstraints { make in
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.centerY.equalToSuperview()
            make.width.equalTo(Layout.logoImageWidth)
            make.height.equalTo(Layout.logoImageHeight)
        }

        helpButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalTo(alarmButton.snp.leading).offset(Layout.headerIconTrailingSpacing)
            make.size.equalTo(Layout.headerViewHeight)
        }

        alarmButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().inset(Layout.headerIconTrailingSpacing)
            make.size.equalTo(Layout.headerViewHeight)
        }

        homeLabel.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(Layout.homeLabelTopSpacing)
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
        }

        registerEmotionButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Layout.horizontalMargin)
            make.top.equalTo(homeLabel.snp.bottom).offset(Layout.registerEmotionButtonTopSpacing)
            make.height.equalTo(Layout.registerEmotionButtonHeight)
            make.width.equalTo(Layout.registerEmotionButtonWidth)
        }

        emotionOrbView.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(Layout.emotionOrbViewTopSpacing)
            make.trailing.equalToSuperview()
            make.size.equalTo(Layout.emotionOrbViewSize)
        }

        contentView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            contentViewTopConstraint = make.top.equalTo(safeArea).offset(Layout.collapsedTop).constraint
            make.bottom.equalToSuperview()
        }

        monthLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.height.equalTo(24)
        }

        previousWeekButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalTo(nextWeekButton.snp.leading)
            make.size.equalTo(48)
        }

        nextWeekButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.size.equalTo(48)
        }

        weekHeaderView.snp.makeConstraints { make in
            make.height.equalTo(48)
        }

        weekView.snp.makeConstraints { make in
//            make.top.equalToSuperview()
//            make.leading.equalTo(safeArea)
//            make.trailing.equalTo(safeArea)
            make.height.equalTo(Layout.weekViewHeight)
        }

        weekStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.horizontalEdges.equalToSuperview()
        }

        routineScrollView.snp.makeConstraints { make in
            make.top.equalTo(weekView.snp.bottom)
            make.horizontalEdges.equalTo(safeArea)
            make.bottom.equalTo(safeArea)
        }

        routineStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Layout.routineStackViewTopSpacing)
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.trailing.equalTo(safeArea).inset(Layout.horizontalMargin)
            make.bottom.equalToSuperview().inset(Layout.routineStackViewBottomSpacing)
        }

        emptyView.snp.makeConstraints { make in
            make.top.equalTo(weekView.snp.bottom).offset(Layout.emptyViewTopSpacing)
            make.centerX.equalToSuperview()
            make.height.equalTo(Layout.emptyViewHeight)
        }

        floatingButton.snp.makeConstraints { make in
            make.trailing.equalTo(safeArea).inset(Layout.horizontalMargin)
            make.bottom.equalTo(safeArea).inset(Layout.floatingButtonBottomSpacing)
            make.size.equalTo(Layout.floatingButtonSize)
        }

        floatingMenu.snp.makeConstraints { make in
            make.trailing.equalTo(safeArea).inset(Layout.horizontalMargin)
            make.bottom.equalTo(floatingButton.snp.top).offset(-Layout.floatingMenuBottomSpacing)
            make.height.equalTo(Layout.floatingMenuHeight)
            make.width.equalTo(Layout.floatingMenuWidth)
        }

        dimmedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        loadingIndicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    override func bind() {
        viewModel.output.nicknamePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] nickname in
                let homeLabelText = "\(nickname)님, 오셨군요!\n오늘 기분은 어떤가요?"
                self?.homeLabel.attributedText = BitnagilFont(
                    family: .cafe24Ssurround,
                    style: .cafe24Title1,
                    weight: .light).attributedString(text: homeLabelText)
            }
            .store(in: &cancellables)

        viewModel.output.selectedDatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedDate in
                self?.monthLabel.text = selectedDate.convertToString(dateType: .yearMonth)
                self?.weekView.updateWeekDateViews(date: selectedDate)
            }
            .store(in: &cancellables)

        viewModel.output.fetchRoutineResultPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] fetchRoutineResult in
                if fetchRoutineResult {
                    self?.viewModel.action(input: .refreshSelectedDateRoutine)
                }
                self?.hideIndicatorView()
            }
            .store(in: &cancellables)

        viewModel.output.routinesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] routines in
                self?.updateRoutineView(routines: routines)
                self?.hideIndicatorView()
            }
            .store(in: &cancellables)

        viewModel.output.emotionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] emotion in
                self?.updateEmotionOrbView(emotion: emotion)
            }
            .store(in: &cancellables)

        viewModel.output.updateRoutineCompletionResultPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isUpdateRoutineCompletion in
                if isUpdateRoutineCompletion {
                    self?.viewModel.action(input: .refreshSelectedDateRoutine)
                    self?.hideIndicatorView()
                }
            }
            .store(in: &cancellables)
    }

    // 해당 날짜의 Routine View를 설정합니다. (없다면 EmptyView)
    private func updateRoutineView(routines: [MainRoutine]) {
        routineStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }

        if routines.isEmpty {
            routineScrollView.isHidden = true
            emptyView.isHidden = false
        } else {
            routineScrollView.isHidden = false
            emptyView.isHidden = true

            for routine in routines {
                let routineView = RoutineView(routine: routine)
                routineView.delegate = self
                routineStackView.addArrangedSubview(routineView)
            }
        }
    }

    // 감정 구슬 View를 업데이트 합니다.
    private func updateEmotionOrbView(emotion: Emotion?) {
        guard
            let emotion,
            let emotionOrbImageUrl = emotion.emotionImageUrl else {
            emotionOrbView.image = BitnagilGraphic.defaultEmotionGraphic
            registerEmotionButton.updateButtonState(buttonState: .default)
            return
        }
        emotionOrbView.kf.setImage(with: emotionOrbImageUrl)
        registerEmotionButton.updateButtonState(buttonState: .disabled)
    }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        let currentTop = contentViewTopConstraint?.layoutConstraints.first?.constant ?? Layout.collapsedTop

        switch gesture.state {
        case .changed:
            let newTop = currentTop + translation.y
            let clampedTop = max(Layout.expandedTop, min(Layout.collapsedTop, newTop))
            contentViewTopConstraint?.update(offset: clampedTop)
            gesture.setTranslation(.zero, in: view)

        case .ended, .cancelled:
            let targetTop: CGFloat
            if velocity.y > 500 {
                targetTop = Layout.collapsedTop
            } else if velocity.y < -500 {
                targetTop = Layout.expandedTop
            } else {
                let midPoint = (Layout.expandedTop + Layout.collapsedTop) / 2
                targetTop = currentTop < midPoint ? Layout.expandedTop : Layout.collapsedTop
            }
            animateToPosition(targetTop)

        default:
            break
        }
    }

    private func animateToPosition(_ targetTop: CGFloat) {
        contentViewTopConstraint?.update(offset: targetTop)
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0,
            options: [.allowUserInteraction]
        ) {
            self.view.layoutIfNeeded()
        }
    }

    private func toggleFloatingButton() {
        floatingButton.toggle()
        isShowingFloatingMenu.toggle()

        floatingMenu.isHidden = !isShowingFloatingMenu
        dimmedView.isHidden = !isShowingFloatingMenu

        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut]) {
            self.dimmedView.alpha = self.isShowingFloatingMenu ? 1 : 0
            self.floatingMenu.alpha = self.isShowingFloatingMenu ? 1 : 0
        }
    }

    @objc private func tappedDimmedView() {
        if isShowingFloatingMenu {
            toggleFloatingButton()
        }
    }

    private func showIndicatorView() {
        loadingIndicatorView.startAnimating()
        contentView.isUserInteractionEnabled = false
    }

    private func hideIndicatorView() {
        loadingIndicatorView.stopAnimating()
        contentView.isUserInteractionEnabled = true
    }

    private func goToEmotionRegisterView() {
        guard let emotionRegisterViewModel = DIContainer.shared.resolve(type: EmotionRegisterViewModel.self) else {
            fatalError("emotionRegisterViewModel 의존성이 등록되지 않았습니다.")
        }
        let emotionRegisterView = EmotionRegisterView(viewModel: emotionRegisterViewModel)
        emotionRegisterView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(emotionRegisterView, animated: true)
    }
}

// MARK: RoutineViewDelegate
extension HomeView: RoutineViewDelegate {
    func routineView(_ sender: RoutineView, didTapMainRoutineCheckButton mainRoutine: MainRoutine) {
        showIndicatorView()
        viewModel.action(input: .updateRoutineCompletion(updatedRoutine: mainRoutine))
    }

    func routineView(_ sender: RoutineView, didTapSubRoutineCheckButton subRoutine: SubRoutine) {
        showIndicatorView()
        viewModel.action(input: .updateRoutineCompletion(updatedRoutine: subRoutine))
    }
}

// MARK: SelectableItemTableViewDelegate
extension HomeView: SelectableItemTableViewDelegate {
    func selectableItemTableView<T: SelectableItem & CaseIterable & Equatable>(_ sender: SelectableItemTableView<T>, didSelectItem: T?) {
        guard let sortType = didSelectItem as? RoutineSortType?
        else { return }

        viewModel.action(input: .selectRoutineSortType(routineSortType: sortType))
    }
}

// MARK: WeekViewDelegate
extension HomeView: WeekViewDelegate {
    func weekView(_ sender: WeekView, didSelectDate date: Date) {
        viewModel.action(input: .selectDate(date: date))
    }
}

// MARK: FloatingMenuViewDelegate
extension HomeView: FloatingMenuViewDelegate {
    func floatingMenuDidTapRegisterRoutineButton(_ sender: FloatingMenuView) {
        toggleFloatingButton()
        guard let routineCreationViewModel = DIContainer.shared.resolve(type: RoutineCreationViewModel.self) else {
            fatalError("routineCreationViewModel 의존성이 등록되지 않았습니다.")
        }
        let routineCreationView = RoutineCreationView(viewModel: routineCreationViewModel)
        routineCreationView.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(routineCreationView, animated: true)
    }
}
