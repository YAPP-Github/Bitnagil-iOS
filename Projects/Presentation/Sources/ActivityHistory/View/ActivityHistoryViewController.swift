//
//  ActivityHistoryViewController.swift
//  Presentation
//
//  Created by 최정인 on 7/1/26.
//

import Combine
import Domain
import FSCalendar
import Shared
import SnapKit
import UIKit

final class ActivityHistoryViewController: BaseViewController<ActivityHistoryViewModel> {
    private enum Layout {
        static let horizontalMargin: CGFloat = 21
        static let navigationBarHeight: CGFloat = 41
        static let badgeSectionBackgroundImageViewHeight: CGFloat = 358
        static let youthOpportunityStackViewSpacing: CGFloat = 12
        static let youthOpportunityViewHeight: CGFloat = 64
        static let youthOpportunityIconSize: CGFloat = 24
        static let youthOpportunityStackViewHorizontalMargin: CGFloat = 20
        static let emotionHistoryLabelTopSpacing: CGFloat = 32
        static let emotionHistoryLabelHeight: CGFloat = 48
        static let emotionCalendarVerticalSpacing: CGFloat = 32
        static let emotionCalendarHeight: CGFloat = 395
    }

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var dimmedView: UIView?

    private let badgeSectionBackgroundImageView = UIImageView()
    private let badgeSectionView = ActivityBadgeSectionView()

    private let youthOpportunityView = UIView()
    private let youthOpportunityStackView = UIStackView()
    private let youthOpportunityIcon = UIImageView()
    private let youthOpportunityLabel = UILabel()
    private let youthOpportunityButton = UIButton()

    private let emotionCalendarSectionView = UIView()
    private let emotionHistoryLabel = UILabel()
    private let emotionCalendarView = EmotionCalendarView()
    private var cancellables: Set<AnyCancellable>

    override init(viewModel: ActivityHistoryViewModel) {
        cancellables = []
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        viewModel.action(input: .invalidateCacheAndRefetch)
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        let bottomInset = view.safeAreaInsets.bottom
        scrollView.contentInset.bottom = bottomInset
        scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
    }

    override func configureAttribute() {
        super.configureAttribute()
        view.backgroundColor = .white

        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        scrollView.contentInsetAdjustmentBehavior = .never

        badgeSectionBackgroundImageView.image = BitnagilGraphic.badgeBackgroundGraphic
        badgeSectionBackgroundImageView.isUserInteractionEnabled = false

        // TODO: 추후 청년공고 API 해결 후 삭제
        youthOpportunityView.isHidden = true

        youthOpportunityView.backgroundColor = BitnagilColor.orange25

        youthOpportunityStackView.axis = .horizontal
        youthOpportunityStackView.alignment = .center
        youthOpportunityStackView.spacing = Layout.youthOpportunityStackViewSpacing

        youthOpportunityIcon.image = BitnagilIcon.reportIcon
        youthOpportunityIcon.contentMode = .scaleAspectFit

        youthOpportunityLabel.text = "청년 공고도 확인할 수 있어요!"
        youthOpportunityLabel.font = BitnagilFont(style: .body2, weight: .semiBold).font
        youthOpportunityLabel.textColor = BitnagilColor.gray10

        youthOpportunityButton.setTitle("더보기", for: .normal)
        youthOpportunityButton.titleLabel?.font = BitnagilFont(style: .body2, weight: .semiBold).font
        youthOpportunityButton.setTitleColor(BitnagilColor.orange500, for: .normal)
        youthOpportunityButton.addAction(
            UIAction { [weak self] _ in
                self?.pushYouthPolicyViewController()
            },
            for: .touchUpInside)

        emotionCalendarSectionView.backgroundColor = .white
        emotionHistoryLabel.text = "감정 구슬 기록"
        emotionHistoryLabel.font = BitnagilFont(style: .title3, weight: .semiBold).font
        emotionHistoryLabel.textColor = BitnagilColor.gray30
    }

    override func configureLayout() {
        super.configureLayout()
        let safeArea = view.safeAreaLayoutGuide

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        badgeSectionBackgroundImageView.addSubview(badgeSectionView)
        [emotionHistoryLabel, emotionCalendarView].forEach {
            emotionCalendarSectionView.addSubview($0)
        }

        [badgeSectionBackgroundImageView, /*youthOpportunityView,*/ emotionCalendarSectionView].forEach {
            contentView.addSubview($0)
        }

        badgeSectionBackgroundImageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(Layout.badgeSectionBackgroundImageViewHeight)
        }

        badgeSectionView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(Layout.navigationBarHeight / 2)
        }

        /*
        youthOpportunityView.addSubview(youthOpportunityStackView)
        let spacerView = UIView()
        [youthOpportunityIcon, youthOpportunityLabel, spacerView, youthOpportunityButton].forEach {
            youthOpportunityStackView.addArrangedSubview($0)
        }
         */

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        // TODO: - 추후 청년공고 API 해결 후 주석처리 제거
        /*
        youthOpportunityView.snp.makeConstraints { make in
            make.top.equalTo(badgeSectionBackgroundImageView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(Layout.youthOpportunityViewHeight)
        }

        youthOpportunityStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(Layout.youthOpportunityStackViewHorizontalMargin)
            make.centerY.equalToSuperview()
        }

        youthOpportunityIcon.snp.makeConstraints { make in
            make.size.equalTo(Layout.youthOpportunityIconSize)
        }
         */

        emotionCalendarSectionView.snp.makeConstraints { make in
            // make.top.equalTo(youthOpportunityView.snp.bottom)
            make.top.equalTo(badgeSectionBackgroundImageView.snp.bottom)
            make.horizontalEdges.equalTo(safeArea)
            make.bottom.equalToSuperview()
        }

        emotionHistoryLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Layout.emotionHistoryLabelTopSpacing)
            make.height.equalTo(Layout.emotionHistoryLabelHeight)
            make.leading.equalToSuperview().inset(Layout.horizontalMargin)
        }

        emotionCalendarView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Layout.emotionCalendarVerticalSpacing)
            make.horizontalEdges.equalToSuperview().inset(Layout.horizontalMargin)
            make.height.equalTo(Layout.emotionCalendarHeight)
            make.bottom.equalToSuperview().inset(Layout.emotionCalendarVerticalSpacing)
        }
    }

    override func bind() {
        emotionCalendarView.dateSelected.sink { [weak self] date, emotion in
            guard let emotion else { return }
            self?.presentEmotionDetail(date: date, emotion: emotion)
        }
        .store(in: &cancellables)

        emotionCalendarView.pageChanged.sink { [weak self] date in
            guard let self else { return }
            self.viewModel.action(input: .fetchMonthlyBadge(date: date))
            self.viewModel.action(input: .fetchEmotionHistory(date: date))
        }
        .store(in: &cancellables)

        viewModel.output.monthlyBadgePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] badge in
                guard let self else { return }
                self.badgeSectionView.configureBadge(badge: badge)
            }
            .store(in: &cancellables)

        viewModel.output.monthlyEmotionHistoryPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] emotionRecords in
                guard let self else { return }
                self.emotionCalendarView.update(records: emotionRecords)
            }
            .store(in: &cancellables)
    }

    private func pushYouthPolicyViewController() {
        guard let youthPolicyViewModel = DIContainer.shared.resolve(type: YouthPolicyViewModel.self)
        else { fatalError("youthPolicyViewModel 의존성이 등록되지 않았습니다.") }

        let youthPolicyViewController = YouthPolicyViewController(viewModel: youthPolicyViewModel)

        navigationController?.pushViewController(youthPolicyViewController, animated: true)
    }

    private func presentEmotionDetail(date: Date, emotion: EmotionMarble) {
        dimmedView?.removeFromSuperview()

        let newDimmedView = UIView()
        newDimmedView.backgroundColor = .black.withAlphaComponent(0.0)
        newDimmedView.frame = view.bounds
        view.addSubview(newDimmedView)
        dimmedView = newDimmedView

        UIView.animate(withDuration: 0.25) {
            newDimmedView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        }

        let emotionDetailViewController = EmotionDetailViewController(date: date, emotion: emotion)
        if let sheet = emotionDetailViewController.sheetPresentationController {
            sheet.prefersGrabberVisible = false
            if #available(iOS 16.0, *) {
                sheet.detents = [.custom { _ in 382 }]
            } else {
                sheet.detents = [.medium()]
            }
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.preferredCornerRadius = 20
        }

        emotionDetailViewController.onDismiss = { [weak self] in
            guard let self else { return }
            guard let dimmedView = self.dimmedView else { return }
            UIView.animate(withDuration: 0.1, animations: {
                dimmedView.alpha = 0
            }, completion: { _ in
                dimmedView.removeFromSuperview()
                self.dimmedView = nil
            })
        }

        present(emotionDetailViewController, animated: true)
    }
}
