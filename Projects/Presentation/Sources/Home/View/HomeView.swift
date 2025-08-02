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
        static let homeLabelTopSpacing: CGFloat = 41
        static let homeLabelHeight: CGFloat = 64
        static let informationButton: CGFloat = 24
        static let informationButtonLeadingSpacing: CGFloat = 1
        static let informationButtonBottomSpacing: CGFloat = 4
        static let informationButtonSize: CGFloat = 24
        static let registerEmotionButtonTopSpacing: CGFloat = 3
        static let registerEmotionButtonHeight: CGFloat = 44
        static let registerEmotionButtonWidth: CGFloat = 136
        static let emotionOrbViewTopSpacing: CGFloat = 46
        static let emotionOrbViewTrailingSpacing: CGFloat = 35
        static let emotionOrbViewSize: CGFloat = 172
        static let contentViewCornerRadius: CGFloat = 20
        static let weekViewHeight: CGFloat = 127
        static let routineSortButtonTrailingSpacing: CGFloat = 8
        static let routineSortButtonSize: CGFloat = 40
        static let routineStackViewSpacing: CGFloat = 21
        static let routineStackViewTopSpacing: CGFloat = 23
        static let routineStackViewBottomSpacing: CGFloat = 100
        static let emptyViewTopSpacing: CGFloat = 77
        static let emptyViewHeight: CGFloat = 120
        static let collapsedTop: CGFloat = 225
        static let expandedTop: CGFloat = 40
        static let floatingButtonBottomSpacing: CGFloat = 19
        static let floatingButtonSize: CGFloat = 52
        static let floatingMenuBottomSpacing: CGFloat = 15
        static let floatingMenuHeight: CGFloat = 64
        static let floatingMenuWidth: CGFloat = 144
        static let tooltipViewTailLeadingSpacing: CGFloat = 78.68
        static let tooltipViewLeadingSpacing: CGFloat = 76
        static let tooltipViewBottomSpacing: CGFloat = 4
        static let tooltipViewWidth: CGFloat = 176
        static let tooltipViewHeight: CGFloat = 47
        static let routineDetailViewDefaultHeight: CGFloat = 367
        static let routineDetailViewSubRoutineHeight: CGFloat = 25
    }

    private let gradientLayer = CAGradientLayer()
    private let homeLabel = UILabel()
    private let informationButton = UIButton()
    private let emotionOrbView = UIImageView()
    private let registerEmotionButton = HomeRegisterEmotionButton()

    private let contentView = UIView()
    private let weekView = WeekView()
    private let emptyView = HomeEmptyView()

    private let routineScrollView = UIScrollView()
    private let routineSortButton = UIButton()
    private let routineSortView = SelectableItemTableView<RoutineSortType>(items: [RoutineSortType.complete, RoutineSortType.incomplete])
    private let routineStackView = UIStackView()

    private let tooltipView = TooltipView(tailPosition: .offsetFromLeading(Layout.tooltipViewTailLeadingSpacing))

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
        configureNavigationBar(navigationStyle: .hidden)
        configureGradientBackground()
        viewModel.action(input: .loadNickname)
        viewModel.action(input: .fetchRoutines)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.action(input: .fetchEmotion)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    override func configureAttribute() {
        homeLabel.text = "님,\n오늘 기분 어때요?"
        homeLabel.numberOfLines = 2
        homeLabel.font = BitnagilFont(style: .title1, weight: .semiBold).font
        homeLabel.textColor = BitnagilColor.gray10

        informationButton.setImage(BitnagilIcon.informationIcon, for: .normal)
        informationButton.addAction(UIAction { [weak self] _ in
            self?.informationButton.isSelected.toggle()
            if self?.informationButton.isSelected ?? false {
                self?.tooltipView.showTooltip()
            } else {
                self?.tooltipView.hideTooltip()
            }
        }, for: .touchUpInside)

        registerEmotionButton.addAction(UIAction { [weak self] _ in
            guard let emotionRegisterViewModel = DIContainer.shared.resolve(type: EmotionRegisterViewModel.self) else {
                fatalError("emotionRegisterViewModel 의존성이 등록되지 않았습니다.")
            }
            let emotionRegisterView = EmotionRegisterView(viewModel: emotionRegisterViewModel)
            emotionRegisterView.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(emotionRegisterView, animated: true)
        }, for: .touchUpInside)

        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = Layout.contentViewCornerRadius
        contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentView.clipsToBounds = true

        let panGesture = UIPanGestureRecognizer()
        panGesture.addTarget(self, action: #selector(handlePanGesture(_:)))
        weekView.addGestureRecognizer(panGesture)
        weekView.isUserInteractionEnabled = true
        weekView.delegate = self

        emptyView.didTapRegisterRoutineButton = {
            guard let routineCreationViewModel = DIContainer.shared.resolve(type: RoutineCreationViewModel.self) else {
                fatalError("routineCreationViewModel 의존성이 등록되지 않았습니다.")
            }
            let routineCreationView = RoutineCreationView(viewModel: routineCreationViewModel)
            routineCreationView.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(routineCreationView, animated: true)
        }

        routineScrollView.showsVerticalScrollIndicator = false
        routineScrollView.showsHorizontalScrollIndicator = false

        routineSortButton.setImage(BitnagilIcon.sortIcon, for: .normal)
        routineSortButton.addAction(UIAction { [weak self] _ in
            self?.showRoutineSortBottomSheet()
        }, for: .touchUpInside)

        routineSortView.delegate = self

        routineStackView.axis = .vertical
        routineStackView.spacing = Layout.routineStackViewSpacing
        routineStackView.alignment = .fill
        routineStackView.distribution = .fill

        tooltipView.configure(message: "감정 기록 시, 루틴을 추천 받아요!")
        tooltipView.isHidden = true
        let viewTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(viewTapGesture)

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
    }

    override func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        view.backgroundColor = .systemBackground

        view.addSubview(homeLabel)
        view.addSubview(informationButton)
        view.addSubview(tooltipView)
        view.addSubview(emotionOrbView)
        view.addSubview(registerEmotionButton)

        view.addSubview(contentView)
        contentView.addSubview(weekView)
        contentView.addSubview(emptyView)
        contentView.addSubview(routineScrollView)
        routineScrollView.addSubview(routineSortButton)
        routineScrollView.addSubview(routineStackView)

        view.addSubview(dimmedView)
        view.addSubview(floatingMenu)
        view.addSubview(floatingButton)

        homeLabel.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(Layout.homeLabelTopSpacing)
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.height.equalTo(Layout.homeLabelHeight)
        }

        informationButton.snp.makeConstraints { make in
            make.leading.equalTo(homeLabel.snp.trailing).offset(Layout.informationButtonLeadingSpacing)
            make.bottom.equalTo(homeLabel.snp.bottom).inset(Layout.informationButtonBottomSpacing)
            make.size.equalTo(Layout.informationButtonSize)
        }

        tooltipView.snp.makeConstraints { make in
            make.leading.equalTo(informationButton).offset(-Layout.tooltipViewLeadingSpacing)
            make.bottom.equalTo(informationButton.snp.top).offset(-Layout.tooltipViewBottomSpacing)
            make.width.equalTo(Layout.tooltipViewWidth)
            make.height.equalTo(Layout.tooltipViewHeight)
        }

        registerEmotionButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
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

        weekView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(safeArea)
            make.trailing.equalTo(safeArea)
            make.height.equalTo(Layout.weekViewHeight)
        }

        routineScrollView.snp.makeConstraints { make in
            make.top.equalTo(weekView.snp.bottom)
            make.horizontalEdges.equalTo(safeArea)
            make.bottom.equalTo(safeArea)
        }

        routineSortButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalTo(safeArea).inset(Layout.routineSortButtonTrailingSpacing)
            make.size.equalTo(Layout.routineSortButtonSize)
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
    }

    override func bind() {
        viewModel.output.nicknamePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] nickname in
                self?.homeLabel.text = "\(nickname)님,\n오늘 기분 어때요?"
            }
            .store(in: &cancellables)

        viewModel.output.fetchRoutineResultPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] fetchRoutineResult in
                if fetchRoutineResult {
                    self?.viewModel.action(input: .fetchDailyRoutines(date: Date()))
                }
            }
            .store(in: &cancellables)

        viewModel.output.routinesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] routines in
                self?.updateRoutineView(routines: routines)
            }
            .store(in: &cancellables)

        viewModel.output.emotionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] emotion in
                self?.updateEmotionOrbView(emotion: emotion)
            }
            .store(in: &cancellables)

    }

    // 홈 Graident 배경색을 설정합니다.
    private func configureGradientBackground() {
        gradientLayer.colors = [
            BitnagilColor.homeGradientLeft?.cgColor ?? UIColor.systemPink.cgColor,
            BitnagilColor.homeGradientRight?.cgColor ?? UIColor.blue.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.9)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    // 루틴 정렬 Bottom Sheet를 보여줍니다.
    private func showRoutineSortBottomSheet() {
        if !tooltipView.isHidden {
            hideTooltipView()
        }
        presentCustomBottomSheet(contentViewController: routineSortView, maxHeight: 192)
    }

    // 해당 날짜의 Routine View를 설정합니다. (없다면 EmptyView)
    private func updateRoutineView(routines: [MainRoutine]) {
        routineStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }

        if routines.isEmpty {
            routineScrollView.isHidden = true
            routineSortButton.isHidden = true
            emptyView.isHidden = false
        } else {
            routineScrollView.isHidden = false
            routineSortButton.isHidden = false
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
            return
        }
        emotionOrbView.kf.setImage(with: emotionOrbImageUrl)
        registerEmotionButton.isEnabled = false
        // TODO: 토스트뷰 보여주기
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
        if !tooltipView.isHidden {
            hideTooltipView()
        }

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
        toggleFloatingButton()
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)

        // 탭한 곳이 버튼 영역인 경우
        if informationButton.frame.contains(location) {
            hideTooltipView()
            return
        }

        // 탭한 곳이 tooltip 영역 밖인 경우
        if !tooltipView.frame.contains(location) {
            hideTooltipView()
        }
    }

    private func hideTooltipView() {
        informationButton.isSelected = false
        tooltipView.hideTooltip()
    }
}

// MARK: RoutineViewDelegate
extension HomeView: RoutineViewDelegate {
    func routineView(_ sender: RoutineView, didTapMainRoutineCheckButton mainRoutine: MainRoutine) {
        sender.updateMainRoutineState(isDone: !mainRoutine.isDone)
        // TODO: 메인 루틴 완료 버튼 체크의 서버 통신을 수행해야 합니다. (viewModel에 action 정의)
    }

    func routineView(_ sender: RoutineView, didTapMainRoutineMoreButton mainRoutine: MainRoutine) {
        let maxHeight = Layout.routineDetailViewDefaultHeight + CGFloat(mainRoutine.subRoutines.count - 1) * Layout.routineDetailViewSubRoutineHeight
        let routineDetailView = RoutineDetailView(routine: mainRoutine)
        routineDetailView.delegate = self
        bottomSheet = CustomBottomSheet(contentViewController: routineDetailView, maxHeight: maxHeight)
        if let bottomSheet {
            present(bottomSheet, animated: true)
        }
    }

    func routineView(_ sender: RoutineView, didTapSubRoutineCheckButton subRoutine: SubRoutine) {
        sender.updateSubRoutineState(subRoutine: subRoutine, isDone: !subRoutine.isDone)
        // TODO: 서브 루틴 완료 버튼 체크의 서버 통신을 수행해야 합니다. (viewModel에 action 정의)
    }
}

// MARK: SelectableItemTableViewDelegate
extension HomeView: SelectableItemTableViewDelegate {
    func selectableItemTableView<T: SelectableItem & CaseIterable & Equatable>(_ sender: SelectableItemTableView<T>, didSelectItem: T?) {
        // TODO: 완료 · 미완료 루틴을 정렬해야 합니다.
    }
}

// MARK: WeekViewDelegate
extension HomeView: WeekViewDelegate {
    func weekView(_ sender: WeekView, didMoveWeek weekStartDate: Date) {
        viewModel.action(input: .fetchDailyRoutines(date: weekStartDate))
    }
    
    func weekView(_ sender: WeekView, didSelectDate date: Date) {
        viewModel.action(input: .fetchDailyRoutines(date: date))
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

// MARK: RoutineDetailViewDelegate
extension HomeView: RoutineDetailViewDelegate {
    func routineDetailView(_ sender: RoutineDetailView, didEditRoutine routine: MainRoutine) {
        if let bottomSheet {
            bottomSheet.dismissBottomSheet()
            self.bottomSheet = nil
        }
        guard let routineCreationViewModel = DIContainer.shared.resolve(type: RoutineCreationViewModel.self) else {
            fatalError("routineCreationViewModel 의존성이 등록되지 않았습니다.")
        }
        let routineCreationView = RoutineCreationView(viewModel: routineCreationViewModel)
        routineCreationView.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(routineCreationView, animated: true)
    }
    
    func routineDetailView(_ sender: RoutineDetailView, didDeleteRoutine routine: MainRoutine) {
        // TODO: 루틴 삭제
    }
}
