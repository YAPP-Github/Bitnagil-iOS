//
//  HomeView.swift
//  Presentation
//
//  Created by 최정인 on 6/15/25.
//

import Combine
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
        static let emotionOrbViewTopSpacing: CGFloat = 81
        static let emotionOrbViewTrailingSpacing: CGFloat = 35
        static let emotionOrbViewSize: CGFloat = 102
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
    }

    private let gradientLayer = CAGradientLayer()
    private let homeLabel = UILabel()
    private let informationButton = UIButton()
    private let emotionOrbView = UIView()
    private let registerEmotionButton = HomeRegisterEmotionButton()

    private let contentView = UIView()
    private let weekView = WeekView()
    private let emptyView = HomeEmptyView()

    private let routineScrollView = UIScrollView()
    private let routineSortButton = UIButton()
    private let routineSortView = SelectableItemTableView<RoutineSortType>(items: [RoutineSortType.complete, RoutineSortType.incomplete])
    private let routineStackView = UIStackView()

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
        viewModel.action(input: .fetchDailyRoutines(date: Date()))
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
        informationButton.addAction(UIAction { _ in
            // TODO: 툴팁 뷰를 보여줘야 합니다.
        }, for: .touchUpInside)

        emotionOrbView.backgroundColor = BitnagilColor.happy
        emotionOrbView.layer.masksToBounds = true
        emotionOrbView.layer.cornerRadius = Layout.emotionOrbViewSize / 2

        registerEmotionButton.addAction(UIAction { _ in
            // TODO: 감정 등록 화면으로 이동해야 합니다.
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
            // TODO: 감정 등록 화면으로 이동해야 합니다.
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
    }

    override func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        view.backgroundColor = .systemBackground

        view.addSubview(homeLabel)
        view.addSubview(informationButton)
        view.addSubview(emotionOrbView)
        view.addSubview(registerEmotionButton)

        view.addSubview(contentView)
        contentView.addSubview(weekView)
        contentView.addSubview(emptyView)
        contentView.addSubview(routineScrollView)
        routineScrollView.addSubview(routineSortButton)
        routineScrollView.addSubview(routineStackView)

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

        registerEmotionButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(homeLabel.snp.bottom).offset(Layout.registerEmotionButtonTopSpacing)
            make.height.equalTo(Layout.registerEmotionButtonHeight)
            make.width.equalTo(Layout.registerEmotionButtonWidth)
        }

        emotionOrbView.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(Layout.emotionOrbViewTopSpacing)
            make.trailing.equalToSuperview().inset(Layout.emotionOrbViewTrailingSpacing)
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
    }

    override func bind() {
        viewModel.output.nicknamePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] nickname in
                self?.homeLabel.text = "\(nickname)님,\n오늘 기분 어때요?"
            }
            .store(in: &cancellables)

        viewModel.output.routinesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] routines in
                self?.updateRoutineView(routines: routines)
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
}

// MARK: RoutineViewDelegate
extension HomeView: RoutineViewDelegate {
    func routineView(_ sender: RoutineView, didTapMainRoutineCheckButton mainRoutine: MainRoutine) {
        sender.updateMainRoutineState(isDone: !mainRoutine.isDone)
        // TODO: 메인 루틴 완료 버튼 체크의 서버 통신을 수행해야 합니다. (viewModel에 action 정의)
    }

    func routineView(_ sender: RoutineView, didTapMainRoutineMoreButton mainRoutine: MainRoutine) {
        // TODO: 더보기 Bottom Sheet
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
        // TODO: 그 전 주 혹은 다음 주 데이터 받아와야 합니다.
    }
    
    func weekView(_ sender: WeekView, didSelectDate date: Date) {
        viewModel.action(input: .fetchDailyRoutines(date: date))
    }
}
