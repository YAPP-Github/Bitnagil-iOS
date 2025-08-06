//
//  RecommendedRoutineView.swift
//  Presentation
//
//  Created by 최정인 on 7/12/25.
//

import Combine
import Domain
import Shared
import SnapKit
import UIKit

final class RecommendedRoutineView: BaseViewController<RecommendedRoutineViewModel> {

    private enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let bottomSheetHeight: CGFloat = 226
        static let categoryViewTopSpacing: CGFloat = 16
        static let categoryViewHeight: CGFloat = 36
        static let headerStackViewTrailingSpacing: CGFloat = 8
        static let headerStackViewTopSpacing: CGFloat = 18
        static let headerStackViewHeight: CGFloat = 40
        static let recommendedRoutineStackViewSpacing: CGFloat = 12
        static let recommendedRoutineScrollViewTopSpacing: CGFloat = 12
        static let recommendedRoutineScrollViewBottomSpacing: CGFloat = 10
        static let recommendedRoutineStackViewBottomSpacing: CGFloat = 50
        static let routineCardHeight: CGFloat = 80
        static let registerEmotionButtonHeight: CGFloat = 52
        static let floatingButtonBottomSpacing: CGFloat = 19
        static let floatingButtonSize: CGFloat = 52
        static let floatingMenuBottomSpacing: CGFloat = 15
        static let floatingMenuHeight: CGFloat = 64
        static let floatingMenuWidth: CGFloat = 144
    }

    private let categoryView = RoutineCategoryView()
    private let headerStackView = UIStackView()
    private let routineLabel = UILabel()
    private let levelButton = RoutineLevelButton()
    private let levelView = SelectableItemTableView<RoutineLevelType>(items: RoutineLevelType.allCases.sorted(by: { $0.id < $1.id }))

    private let recommendedRoutineScrollView = UIScrollView()
    private let recommendedRoutineStackView = UIStackView()
    private var recommendedRoutineCards: [Int: RecommendedRoutineCardView] = [:]
    private let registerEmotionButton = RegisterEmotionButton()

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
        title = "추천 루틴"
        categoryView.delegate = self

        routineLabel.text = "루틴 목록"
        routineLabel.font = BitnagilFont(style: .body1, weight: .semiBold).font
        routineLabel.textColor = BitnagilColor.gray10

        headerStackView.axis = .horizontal

        levelButton.addAction(UIAction { _ in
            self.showBottomSheet()
        }, for: .touchUpInside)

        levelView.delegate = self

        recommendedRoutineScrollView.showsVerticalScrollIndicator = false

        recommendedRoutineStackView.axis = .vertical
        recommendedRoutineStackView.spacing = Layout.recommendedRoutineStackViewSpacing

        registerEmotionButton.addAction(UIAction { _ in
            guard let emotionRegisterViewModel = DIContainer.shared.resolve(type: EmotionRegisterViewModel.self) else {
                fatalError("emotionRegisterViewModel 의존성이 등록되지 않았습니다.")
            }
            let emotionRegisterView = EmotionRegisterView(viewModel: emotionRegisterViewModel)
            emotionRegisterView.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(emotionRegisterView, animated: true)
        }, for: .touchUpInside)

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
    }

    override func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        view.backgroundColor = .systemBackground

        view.addSubview(categoryView)
        view.addSubview(headerStackView)
        [routineLabel, levelButton].forEach {
            headerStackView.addArrangedSubview($0)
        }
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

        headerStackView.snp.makeConstraints { make in
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.trailing.equalTo(safeArea).inset(Layout.headerStackViewTrailingSpacing)
            make.top.equalTo(categoryView.snp.bottom).offset(Layout.headerStackViewTopSpacing)
            make.height.equalTo(Layout.headerStackViewHeight)
        }

        routineLabel.snp.makeConstraints { make in
            make.leading.equalTo(headerStackView)
        }

        levelButton.snp.makeConstraints { make in
            make.trailing.equalTo(headerStackView)
        }

        recommendedRoutineScrollView.snp.makeConstraints { make in
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.trailing.equalTo(safeArea).inset(Layout.horizontalMargin)
            make.top.equalTo(headerStackView.snp.bottom).offset(Layout.recommendedRoutineScrollViewTopSpacing)
            make.bottom.equalTo(safeArea).inset(Layout.recommendedRoutineScrollViewBottomSpacing)
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
                self?.showEmotionButton(isShowEmotionButton: selectedCategory == .recommendation)
                self?.categoryView.updateSelectedCategory(selectedCategory: selectedCategory)
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
                    self?.registerEmotionButton.isHidden = true
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

        for routine in recommendedRoutines {
            let routineCard = RecommendedRoutineCardView(recommendedRoutine: routine)
            recommendedRoutineCards[routine.id] = routineCard
            recommendedRoutineStackView.addArrangedSubview(routineCard)
            routineCard.delegate = self
            routineCard.snp.makeConstraints { make in
                make.height.equalTo(Layout.routineCardHeight)
            }
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
        guard !isExistEmotion else {
            registerEmotionButton.isHidden = true
            return
        }
        
        guard isShowEmotionButton else {
            registerEmotionButton.isHidden = true
            return
        }
        guard !recommendedRoutineStackView.arrangedSubviews.contains(registerEmotionButton) else {
            registerEmotionButton.isHidden = false
            return
        }

        recommendedRoutineStackView.addArrangedSubview(registerEmotionButton)
        registerEmotionButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Layout.registerEmotionButtonHeight)
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
extension RecommendedRoutineView: RoutineCategoryViewDelegate {
    func routineCategoryView(_ sender: RoutineCategoryView, didSelectCategory category: RoutineCategoryType) {
        viewModel.action(input: .selectCategory(selectedCategory: category))
    }
}

// MARK: RecommendedRoutineCardViewDelegate
extension RecommendedRoutineView: RecommendedRoutineCardViewDelegate {
    func recommendedRoutineCardView(_ sender: RecommendedRoutineCardView, didTapRecommendedRoutine routine: RecommendedRoutine) {
        // TODO: 루틴 등록하기 화면으로 이동해야 함 + 추천 루틴 들고
    }
}

// MARK: SelectableItemTableViewDelegate
extension RecommendedRoutineView: SelectableItemTableViewDelegate {
    func selectableItemTableView<T: SelectableItem & CaseIterable & Equatable>(_ sender: SelectableItemTableView<T>, didSelectItem: T?) {
        guard let didSelectLevel = didSelectItem as? RoutineLevelType?
        else { return }
        viewModel.action(input: .selectLevel(selectedLevel: didSelectLevel))
        levelButton.updateButton(level: didSelectLevel)
    }
}

// MARK: FloatingMenuViewDelegate
extension RecommendedRoutineView: FloatingMenuViewDelegate {
    func floatingMenuDidTapRegisterRoutineButton(_ sender: FloatingMenuView) {
        toggleFloatingButton()
        guard let routineCreationViewModel = DIContainer.shared.resolve(type: RoutineCreationViewModel.self) else {
            fatalError("routineCreationViewModel 의존성이 등록되지 않았습니다.")
        }
        let routineCreationView = RoutineCreationView(viewModel: routineCreationViewModel)
        self.navigationController?.pushViewController(routineCreationView, animated: true)
    }
}
