//
//  RecommendedRoutineViewController.swift
//  Presentation
//
//  Created by 최정인 on 7/12/25.
//

import Combine
import Domain
import Shared
import SnapKit
import UIKit

final class RecommendedRoutineViewController: BaseViewController<RecommendedRoutineViewModel> {
    private enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let bottomSheetHeight: CGFloat = 226
        static let categoryViewTopSpacing: CGFloat = 70
        static let categoryViewHeight: CGFloat = 36
        static let headerStackViewTrailingSpacing: CGFloat = 8
        static let headerStackViewTopSpacing: CGFloat = 20
        static let headerStackViewTopMaxSpacing: CGFloat = 24
        static let headerStackViewHeight: CGFloat = 40
        static let recommendedRoutineStackViewSpacing: CGFloat = 12
        static let recommendedRoutineScrollViewTopSpacing: CGFloat = 12
        static let recommendedRoutineStackViewBottomSpacing: CGFloat = 65
        static let routineCardHeight: CGFloat = 80
        static let registerEmotionButtonTopSpacing: CGFloat = 20
        static let registerEmotionButtonHeight: CGFloat = 66
        static let floatingButtonBottomSpacing: CGFloat = 19
        static let floatingButtonSize: CGFloat = 52
        static let floatingMenuBottomSpacing: CGFloat = 15
        static let floatingMenuHeight: CGFloat = 64
        static let floatingMenuWidth: CGFloat = 144
        static let toastMessageBottomSpacing: CGFloat = 19
    }

    private let categoryView = RoutineCategoryView()
    private let headerStackView = UIStackView()
    private let routineLabel = UILabel()
    private let levelButton = RoutineLevelButton()
    private let levelView = SelectableItemTableView<RoutineLevelType>(items: RoutineLevelType.allCases.sorted(by: { $0.id < $1.id }))

    private let recommendedRoutineScrollView = UIScrollView()
    private let recommendedRoutineStackView = UIStackView()
    private var recommendedRoutineCards: [Int: RoutineCardView] = [:]
    private let registerEmotionButton = RegisterEmotionButtonView()
    private let recommendedRoutineEmptyView = RecommendedRoutineEmptyView()

    private var isExistEmotion: Bool = false
    private var isShowingFloatingMenu: Bool = false
    private let dimmedView = UIView()
    private let floatingButton = FloatingButton()
    private let floatingMenu = FloatingMenuView()
    private var cancellables: Set<AnyCancellable>

    public override init(viewModel: RecommendedRoutineViewModel) {
        cancellables = []
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.action(input: .fetchRecommendedRoutines)
        viewModel.action(input: .loadEmotion)
    }

    override func configureAttribute() {
        categoryView.delegate = self

        routineLabel.text = "추천 루틴리스트"
        routineLabel.font = BitnagilFont(style: .body2, weight: .semiBold).font
        routineLabel.textColor = BitnagilColor.gray60

        headerStackView.axis = .horizontal

        levelButton.addAction(UIAction { _ in
            self.showBottomSheet()
        }, for: .touchUpInside)

        levelView.delegate = self

        recommendedRoutineScrollView.showsVerticalScrollIndicator = false

        recommendedRoutineStackView.axis = .vertical
        recommendedRoutineStackView.spacing = Layout.recommendedRoutineStackViewSpacing

        registerEmotionButton.delegate = self

        floatingButton.addAction(UIAction { [weak self] _ in
            self?.toggleFloatingButton()
        }, for: .touchUpInside)

        floatingMenu.isHidden = true
        floatingMenu.delegate = self

        dimmedView.isHidden = true
        dimmedView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        dimmedView.alpha = 0

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedDimmedView))
        dimmedView.addGestureRecognizer(tapGesture)

        recommendedRoutineEmptyView.isHidden = true
    }

    override func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        view.backgroundColor = BitnagilColor.gray99
        navigationController?.setNavigationBarHidden(true, animated: false)
        configureCustomNavigationBar(navigationBarStyle: .withTitle(title: "추천 루틴"), backgroundColor: BitnagilColor.gray99)

        view.addSubview(categoryView)
        view.addSubview(registerEmotionButton)
        view.addSubview(headerStackView)
        [routineLabel, levelButton].forEach {
            headerStackView.addArrangedSubview($0)
        }
        view.addSubview(recommendedRoutineEmptyView)
        view.addSubview(recommendedRoutineScrollView)
        recommendedRoutineScrollView.addSubview(recommendedRoutineStackView)

        view.addSubview(dimmedView)
        view.addSubview(floatingMenu)
        view.addSubview(floatingButton)

        categoryView.snp.makeConstraints { make in
            make.leading.equalTo(safeArea)
            make.trailing.equalTo(safeArea)
            make.top.equalTo(safeArea).offset(Layout.categoryViewTopSpacing)
            make.height.equalTo(Layout.categoryViewHeight)
        }

        registerEmotionButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Layout.horizontalMargin)
            make.trailing.equalToSuperview().inset(Layout.horizontalMargin)
            make.top.equalTo(categoryView.snp.bottom).offset(Layout.registerEmotionButtonTopSpacing)
            make.height.equalTo(Layout.registerEmotionButtonHeight)
        }

        headerStackView.snp.makeConstraints { make in
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.trailing.equalTo(safeArea).inset(Layout.headerStackViewTrailingSpacing)
            make.top.equalTo(registerEmotionButton.snp.bottom).offset(Layout.headerStackViewTopSpacing)
            make.height.equalTo(Layout.headerStackViewHeight)
        }

        routineLabel.snp.makeConstraints { make in
            make.leading.equalTo(headerStackView)
        }

        levelButton.snp.makeConstraints { make in
            make.trailing.equalTo(headerStackView)
        }

        recommendedRoutineEmptyView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(Layout.headerStackViewHeight)
        }

        recommendedRoutineScrollView.snp.makeConstraints { make in
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.trailing.equalTo(safeArea).inset(Layout.horizontalMargin)
            make.top.equalTo(headerStackView.snp.bottom).offset(Layout.recommendedRoutineScrollViewTopSpacing)
            make.bottom.equalTo(safeArea)
        }

        recommendedRoutineStackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(Layout.recommendedRoutineStackViewBottomSpacing)
            make.width.equalTo(recommendedRoutineScrollView.snp.width)
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
        viewModel.output.selectedCategoryPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedCategory in
                self?.categoryView.updateSelectedCategory(selectedCategory: selectedCategory)
                self?.showEmotionButton(isShowEmotionButton: selectedCategory == .recommendation)
                self?.recommendedRoutineScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            }
            .store(in: &cancellables)

        viewModel.output.recommendedRoutinePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] recommendedRoutines in
                self?.fetchRecommendedRoutines(recommendedRoutines: recommendedRoutines)
            }
            .store(in: &cancellables)

        viewModel.output.emotionExistPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isExistEmotion in
                if isExistEmotion {
                    self?.isExistEmotion = isExistEmotion
                    self?.showEmotionButton(isShowEmotionButton: false)
                }
            }
            .store(in: &cancellables)
    }

    // 추천 루틴 카드 View
    private func fetchRecommendedRoutines(recommendedRoutines: [RecommendedRoutine]) {
        recommendedRoutineStackView.arrangedSubviews.forEach { view in
            if view != registerEmotionButton {
                recommendedRoutineStackView.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
        }
        recommendedRoutineCards.removeAll()

        recommendedRoutineEmptyView.isHidden = !recommendedRoutines.isEmpty
        for routine in recommendedRoutines {
            let routineCardView = RoutineCardView(routine: routine)
            recommendedRoutineCards[routine.id] = routineCardView
            routineCardView.delegate = self
            recommendedRoutineStackView.addArrangedSubview(routineCardView)
        }
    }

    // Bottom Sheet(난이도 필터링)를 보여줍니다.
    private func showBottomSheet() {
        if isShowingFloatingMenu {
            toggleFloatingButton()
        }
        presentCustomBottomSheet(contentViewController: levelView, maxHeight: Layout.bottomSheetHeight)
    }

    // 감정 등록 버튼을 보이거나 숨겨줍니다.
    private func showEmotionButton(isShowEmotionButton: Bool) {
        let safeArea = view.safeAreaLayoutGuide
        let showingEmotionButton = isShowEmotionButton && !isExistEmotion
        registerEmotionButton.isHidden = !showingEmotionButton

        headerStackView.snp.remakeConstraints { make in
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.trailing.equalTo(safeArea).inset(Layout.headerStackViewTrailingSpacing)
            make.height.equalTo(Layout.headerStackViewHeight)

            if showingEmotionButton {
                make.top.equalTo(registerEmotionButton.snp.bottom).offset(Layout.headerStackViewTopSpacing)
            } else {
                make.top.equalTo(categoryView.snp.bottom).offset(Layout.headerStackViewTopMaxSpacing)
            }
        }
    }

    // 플로팅 버튼을 토글합니다. (플로팅 버튼 동작 및 플로팅 메뉴 등장)
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
        toggleFloatingButton()
    }
}

// MARK: RoutineCategoryViewDelegate
extension RecommendedRoutineViewController: RoutineCategoryViewDelegate {
    func routineCategoryView(_ sender: RoutineCategoryView, didSelectCategory category: RoutineCategoryType) {
        viewModel.action(input: .selectCategory(selectedCategory: category))
    }
}

// MARK: SelectableItemTableViewDelegate
extension RecommendedRoutineViewController: SelectableItemTableViewDelegate {
    func selectableItemTableView<T: SelectableItem & CaseIterable & Equatable>(_ sender: SelectableItemTableView<T>, didSelectItem: T?) {
        guard let didSelectLevel = didSelectItem as? RoutineLevelType?
        else { return }
        viewModel.action(input: .selectLevel(selectedLevel: didSelectLevel))
        levelButton.updateButton(level: didSelectLevel)
        recommendedRoutineScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
}

// MARK: FloatingMenuViewDelegate
extension RecommendedRoutineViewController: FloatingMenuViewDelegate {
    func floatingMenuDidTapRegisterRoutineButton(_ sender: FloatingMenuView) {
        toggleFloatingButton()
        guard let routineCreationViewModel = DIContainer.shared.resolve(type: RoutineCreationViewModel.self)
        else { fatalError("routineCreationViewModel 의존성이 등록되지 않았습니다.") }
        
        let routineCreationView = RoutineCreationViewController(viewModel: routineCreationViewModel)
        routineCreationView.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(routineCreationView, animated: true)
    }
}

// MARK: RegisterEmotionButtonViewDelegate
extension RecommendedRoutineViewController: RegisterEmotionButtonViewDelegate {
    func registerEmotionButtonViewDidTapRegisterButton(_ sender: RegisterEmotionButtonView) {
        guard let emotionRegisterViewModel = DIContainer.shared.resolve(type: EmotionRegisterViewModel.self)
        else { fatalError("emotionRegisterViewModel 의존성이 등록되지 않았습니다.") }

        let emotionRegisterView = EmotionRegisterView(viewModel: emotionRegisterViewModel)
        emotionRegisterView.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(emotionRegisterView, animated: true)
    }
}

// MARK: RoutineCardViewDelegate
extension RecommendedRoutineViewController: RoutineCardViewDelegate {
    func routineCardView(_ sender: RoutineCardView, didTapPlusButton routine: RecommendedRoutine) {
        guard let routineCreationViewModel = DIContainer.shared.resolve(type: RoutineCreationViewModel.self)
        else { fatalError("routineCreationViewModel 의존성이 등록되지 않았습니다.") }

        let routineCreationView = RoutineCreationViewController(viewModel: routineCreationViewModel, recommendRoutineId: routine.id)
        routineCreationView.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(routineCreationView, animated: true)
    }
}
