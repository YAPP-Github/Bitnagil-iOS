//
//  HomeView.swift
//  Presentation
//
//  Created by 최정인 on 6/15/25.
//

import Combine
import Shared
import SnapKit
import Then
import UIKit

final class HomeView: BaseViewController<HomeViewModel> {

    private let gradientLayer = CAGradientLayer()
    private let homeLabel = UILabel()
    private let informationButton = UIButton()
    private let emotionOrbView = UIView()
    private let registerEmotionButton = HomeRegisterEmotionButton()
    private let contentView = UIView()
    private let weekView = WeekView()
    private let emptyView = HomeEmptyView()
    private let registerRoutineButton = UIButton()

    private let routineScrollView = UIScrollView()
    private let routineStackView = UIStackView()

    private var contentViewTopConstraint: Constraint?
    private let panGesture = UIPanGestureRecognizer()

    private let collapsedTop: CGFloat = 225
    private let expandedTop: CGFloat = 40

    private let routineView = RoutineView(routine: mainRoutine1)
    private var cancellables: Set<AnyCancellable>
    private var routines: [MainRoutine] = []

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
        setupPanGesture()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    override func configureAttribute() {
        homeLabel.text = "선영님,\n오늘 기분 어때요?"
        homeLabel.numberOfLines = 2
        homeLabel.font = BitnagilFont(style: .title1, weight: .semiBold).font
        homeLabel.textColor = BitnagilColor.gray10

        informationButton.setImage(BitnagilIcon.informationIcon, for: .normal)
        informationButton.addAction(UIAction { _ in
            // TODO: 툴팁 뷰를 보여줘야 합니다.
        }, for: .touchUpInside)

        registerEmotionButton.addAction(UIAction { _ in
            // TODO: 감정 등록 화면으로 이동해야 합니다.
        }, for: .touchUpInside)

        emotionOrbView.backgroundColor = BitnagilColor.happy
        emotionOrbView.layer.masksToBounds = true
        emotionOrbView.layer.cornerRadius = 102 / 2

        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 20
        contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentView.clipsToBounds = true

        emptyView.didTapRegisterRoutineButton = {
            // TODO: 감정 등록 화면으로 이동해야 합니다.
        }
        routineScrollView.showsVerticalScrollIndicator = false
        routineScrollView.showsHorizontalScrollIndicator = false

        routineStackView.axis = .vertical
        routineStackView.spacing = 21
        routineStackView.alignment = .fill
        routineStackView.distribution = .fill

        routineView.delegate = self
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
        contentView.addSubview(routineScrollView)
        contentView.addSubview(emptyView)

        routineScrollView.addSubview(routineStackView)

        homeLabel.snp.makeConstraints { make in
            make.leading.equalTo(safeArea).offset(20)
            make.top.equalTo(safeArea).offset(41)
            make.height.equalTo(64)
        }

        informationButton.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.leading.equalTo(homeLabel.snp.trailing).offset(1)
            make.bottom.equalTo(homeLabel.snp.bottom).inset(4)
        }

        registerEmotionButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(homeLabel.snp.bottom).offset(3)
            make.height.equalTo(44)
            make.width.equalTo(136)
        }

        emotionOrbView.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(81)
            make.trailing.equalToSuperview().inset(35)
            make.size.equalTo(102)
        }

        contentView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            contentViewTopConstraint = make.top.equalTo(safeArea).offset(collapsedTop).constraint
            make.bottom.equalToSuperview()
        }

        weekView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(safeArea)
            make.trailing.equalTo(safeArea)
            make.height.equalTo(127)
        }

        routineScrollView.snp.makeConstraints { make in
            make.top.equalTo(weekView.snp.bottom).offset(23)
            make.leading.equalTo(safeArea).offset(20)
            make.trailing.equalTo(safeArea).inset(20)
            make.bottom.equalTo(safeArea).inset(100)
        }

        routineStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(routineScrollView.snp.width)
        }

        emptyView.snp.makeConstraints { make in
            make.top.equalTo(weekView.snp.bottom).offset(77)
            make.centerX.equalToSuperview()
            make.height.equalTo(120)
        }

        //        routineView.snp.makeConstraints { make in
        //            make.leading.equalTo(safeArea).offset(20)
        //            make.trailing.equalTo(safeArea).inset(20)
        //            make.top.equalTo(weekView.snp.bottom).offset(20)
        //            make.height.equalTo(237)
        //        }
    }

    override func bind() {
    }

    private func configureGradientBackground() {
        gradientLayer.colors = [
            BitnagilColor.homeGradientLeft?.cgColor ?? UIColor.systemPink.cgColor,
            BitnagilColor.homeGradientRight?.cgColor ?? UIColor.blue.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.9)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupPanGesture() {
        panGesture.addTarget(self, action: #selector(handlePanGesture(_:)))
        weekView.addGestureRecognizer(panGesture)
        weekView.isUserInteractionEnabled = true
    }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)

        let currentTop = contentViewTopConstraint?.layoutConstraints.first?.constant ?? collapsedTop

        switch gesture.state {
        case .changed:
            let newTop = currentTop + translation.y
            let clampedTop = max(expandedTop, min(collapsedTop, newTop))
            contentViewTopConstraint?.update(offset: clampedTop)
            gesture.setTranslation(.zero, in: view)

        case .ended, .cancelled:
            let targetTop: CGFloat
            if velocity.y > 500 {
                targetTop = collapsedTop
            } else if velocity.y < -500 {
                targetTop = expandedTop
            } else {
                let midPoint = (expandedTop + collapsedTop) / 2
                targetTop = currentTop < midPoint ? expandedTop : collapsedTop
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

    private func setupRoutineData() {

    }
}

// MARK: RoutineViewDelegate
extension HomeView: RoutineViewDelegate {
    func routineView(_ sender: RoutineView, didTapMainRoutineCheckButton mainRoutine: MainRoutine) {
        sender.updateMainRoutineState(isDone: !mainRoutine.isDone)
    }

    func routineView(_ sender: RoutineView, didTapMainRoutineMoreButton mainRoutine: MainRoutine) {
        // TODO: 더보기 Bottom Sheet
        print("\(mainRoutine.title)")
    }

    func routineView(_ sender: RoutineView, didTapSubRoutineCheckButton subRoutine: SubRoutine) {
        sender.updateSubRoutineState(subRoutine: subRoutine, isDone: !subRoutine.isDone)
    }
}
