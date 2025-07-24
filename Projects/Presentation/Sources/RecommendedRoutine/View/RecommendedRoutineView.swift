//
//  RecommendedRoutineView.swift
//  Presentation
//
//  Created by 최정인 on 7/12/25.
//

import Combine
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
    private var cancellables: Set<AnyCancellable>

    public override init(viewModel: RecommendedRoutineViewModel) {
        cancellables = []
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.action(input: .fetchRecommendedRoutines(selectedCategory: .recommendation))
    }

    public override func configureAttribute() {
        title = "추천 루틴"
        categoryView.delegate = self

        routineLabel.do {
            $0.text = "루틴 목록"
            $0.font = BitnagilFont(style: .body1, weight: .semiBold).font
            $0.textColor = BitnagilColor.gray10
        }

        headerStackView.do {
            $0.axis = .horizontal
        }

        levelButton.addAction(UIAction { _ in
            self.showBottomSheet()
        }, for: .touchUpInside)

        levelView.delegate = self

        recommendedRoutineScrollView.do {
            $0.showsVerticalScrollIndicator = false
        }

        recommendedRoutineStackView.do {
            $0.axis = .vertical
            $0.spacing = Layout.recommendedRoutineStackViewSpacing
        }
    }

    public override func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        view.backgroundColor = .systemBackground

        view.addSubview(categoryView)
        view.addSubview(headerStackView)
        [routineLabel, levelButton].forEach {
            headerStackView.addArrangedSubview($0)
        }
        view.addSubview(recommendedRoutineScrollView)
        recommendedRoutineScrollView.addSubview(recommendedRoutineStackView)

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
    }

    public override func bind() {
        viewModel.output.selectedCategoryPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedCategory in
                self?.categoryView.updateSelectedCategory(selectedCategory: selectedCategory)
            }
            .store(in: &cancellables)

        viewModel.output.recommendedRoutinePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] recommendedRoutines in
                self?.fetchRecommendedRoutines(recommendedRoutines: recommendedRoutines)
            }
            .store(in: &cancellables)
    }

    private func fetchRecommendedRoutines(recommendedRoutines: [RecommendedRoutine]) {
        recommendedRoutineStackView.arrangedSubviews.forEach { view in
            recommendedRoutineStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
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

        if !recommendedRoutines.isEmpty && recommendedRoutines[0].routineCategory == .recommendation {
            showEmotionButton()
        }
    }

    private func showBottomSheet() {
        presentCustomBottomSheet(contentViewController: levelView, maxHeight: Layout.bottomSheetHeight)
    }

    private func showEmotionButton() {
        recommendedRoutineStackView.addArrangedSubview(registerEmotionButton)

        registerEmotionButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Layout.registerEmotionButtonHeight)
        }
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
