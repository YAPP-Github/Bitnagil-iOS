//
//  ReportHistoryViewController.swift
//  Presentation
//
//  Created by 이동현 on 11/15/25.
//

import Combine
import Domain
import Shared
import SnapKit
import UIKit

final class ReportHistoryViewController: BaseViewController<ReportHistoryViewModel> {
    private enum Layout {
        static let horizontalSpacing: CGFloat = 20
        static let progressCollectionViewTopSpacing: CGFloat = 80
        static let progressCollectionViewHeight: CGFloat = 36
        static let progressCollectionViewWidth: CGFloat = 48
        static let progressCellSpacing: CGFloat = 8
        static let historyTableViewTopSpacing: CGFloat = 34
        static let historyTableFooterHeight: CGFloat = 24
        static let historyTableHeaderHeight: CGFloat = 30
        static let historyTableViewCellHeight: CGFloat = 122
        static let historyCellSpacing: CGFloat = 10
        static let categoryButtonLabelHeight: CGFloat = 20
        static let categoryButtonLabelWidth: CGFloat = 52
        static let categoryButtonTopSpacing: CGFloat = 2
        static let categoryButtonImageSize: CGFloat = 16
        static let categoryButtonImageLeadingSpacing: CGFloat = 5
        static let cetegoryButtonHeight: CGFloat = 40
        static let emptyHistoryViewHeight: CGFloat = 50
        static let emptyHistoryViewWidth: CGFloat = 269
        static let categoryBottomSheetHeight: CGFloat = 362
    }

    private enum ProgressSection {
        case main
    }

    private let progressCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    private let categoryLabel = UILabel()
    private let categoryButtonImage = UIImageView()
    private let categoryButton = UIButton()
    private let historyTableView = UITableView(frame: .zero, style: .grouped)
    private let historyEmptyView = ReportHistoryEmptyView()
    private var progressDataSource: UICollectionViewDiffableDataSource<ProgressSection, ReportProgressItem>?
    private var historyDataSource: UITableViewDiffableDataSource<String, ReportHistoryItem>?
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.action(input: .fetchReports)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureCustomNavigationBar(navigationBarStyle: .withBackButton(title: "내 제보 기록"), backgroundColor: BitnagilColor.gray99)
    }

    override func configureAttribute() {
        view.backgroundColor = BitnagilColor.gray99

        categoryLabel.textColor = BitnagilColor.gray40
        categoryLabel.font = BitnagilFont.init(style: .body2, weight: .medium).font
        categoryButton.backgroundColor = .clear
        categoryButton.addAction(
            UIAction { [weak self] _ in
                self?.showCategoryBottomSheet()
            },
            for: .touchUpInside)

        categoryButtonImage.image = BitnagilIcon
            .chevronIcon(direction: .down)?
            .withRenderingMode(.alwaysTemplate)
        categoryButtonImage.tintColor = BitnagilColor.gray40

        configureProgressCollectionView()
        configureHistoryTableView()
    }

    override func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide

        view.addSubview(progressCollectionView)
        view.addSubview(historyTableView)
        view.addSubview(categoryLabel)
        view.addSubview(categoryButtonImage)
        view.addSubview(categoryButton)
        view.addSubview(historyEmptyView)

        progressCollectionView.snp.makeConstraints { make in
            make.top
                .equalTo(safeArea.snp.top)
                .offset(Layout.progressCollectionViewTopSpacing)

            make.horizontalEdges
                .equalToSuperview()
                .inset(Layout.horizontalSpacing)

            make.height.equalTo(Layout.progressCollectionViewHeight)
        }

        historyTableView.snp.makeConstraints { make in
            make.horizontalEdges
                .equalToSuperview()
                .inset(Layout.horizontalSpacing)

            make.top
                .equalTo(progressCollectionView.snp.bottom)
                .offset(Layout.historyTableViewTopSpacing)

            make.bottom.equalToSuperview()
        }

        categoryButtonImage.snp.makeConstraints { make in
            make.top
                .equalTo(historyTableView.snp.top)
                .offset(Layout.categoryButtonTopSpacing)

            make.trailing
                .equalToSuperview()
                .offset(-Layout.horizontalSpacing)

            make.size.equalTo(Layout.categoryButtonImageSize)
        }

        categoryLabel.snp.makeConstraints { make in
            make.trailing
                .equalTo(categoryButtonImage.snp.leading)
                .offset(-Layout.categoryButtonImageLeadingSpacing)

            make.centerY.equalTo(categoryButtonImage)
        }

        categoryButton.snp.makeConstraints { make in
            make.centerY.equalTo(categoryButtonImage)

            make.leading.equalTo(categoryLabel.snp.leading)

            make.trailing
                .equalToSuperview()
                .offset(-Layout.horizontalSpacing)

            make.height.equalTo(Layout.cetegoryButtonHeight)
        }

        historyEmptyView.snp.makeConstraints { make in
            make.center.equalToSuperview()

            make.width.equalTo(Layout.emptyHistoryViewWidth)

            make.height.equalTo(Layout.emptyHistoryViewHeight)
        }
    }

    override func bind() {
        viewModel.output.categoryPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { reportTypes in
                
            })
            .store(in: &cancellables)

        viewModel.output.selectedCategoryPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] selectedCategory in
                if let selectedCategory {
                    self?.categoryLabel.text = selectedCategory.name
                } else {
                    self?.categoryLabel.text = "카테고리"
                }
            })
            .store(in: &cancellables)

        viewModel.output.progressPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] progresses in
                self?.applyProgressSnapshot(items: progresses)
            })
            .store(in: &cancellables)

        viewModel.output.reportsPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] reports in
                self?.historyEmptyView.isHidden = !reports.isEmpty
                self?.applyHistorySnapshot(reports: reports)
            })
            .store(in: &cancellables)

        viewModel.output.selectedReportPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { selectedReport in

            })
            .store(in: &cancellables)
    }

    private func configureProgressCollectionView() {
        progressCollectionView.backgroundColor = .clear
        progressCollectionView.bounces = false
        progressCollectionView.showsHorizontalScrollIndicator = false

        progressCollectionView.setCollectionViewLayout(createProgressLayout(), animated: false)

        progressCollectionView.register(ReportProgressCollectionViewCell.self, forCellWithReuseIdentifier: ReportProgressCollectionViewCell.className)

        progressDataSource = UICollectionViewDiffableDataSource<ProgressSection, ReportProgressItem>(collectionView: progressCollectionView) {  collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReportProgressCollectionViewCell.className, for: indexPath) as? ReportProgressCollectionViewCell else { return UICollectionViewCell() }

            cell.configure(with: item)
            return cell
        }

        progressCollectionView.delegate = self
    }

    private func createProgressLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .estimated(Layout.progressCollectionViewWidth),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(Layout.progressCollectionViewWidth), heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(Layout.progressCellSpacing)

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = Layout.progressCellSpacing
        section.contentInsets = .zero

        return UICollectionViewCompositionalLayout(section: section)
    }

    private func configureHistoryTableView() {
        historyTableView.backgroundColor = .clear
        historyTableView.separatorStyle = .none
        historyTableView.showsVerticalScrollIndicator = false
        historyTableView.rowHeight = UITableView.automaticDimension
        historyTableView.estimatedRowHeight = Layout.historyTableViewCellHeight
        historyTableView.sectionHeaderTopPadding = CGFloat.zero
        historyTableView.sectionHeaderHeight = Layout.historyTableHeaderHeight
        historyTableView.sectionFooterHeight = Layout.historyTableFooterHeight

        
        historyTableView.register(ReportHistoryTableViewCell.self, forCellReuseIdentifier: ReportHistoryTableViewCell.className)
        historyTableView.register(ReportHistoryTableHeaderView.self, forHeaderFooterViewReuseIdentifier: ReportHistoryTableHeaderView.className)
        
        historyDataSource = UITableViewDiffableDataSource<String, ReportHistoryItem>(tableView: historyTableView) { tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ReportHistoryTableViewCell.className, for: indexPath) as? ReportHistoryTableViewCell else { return UITableViewCell() }

            cell.configure(with: item)
            return cell
        }

        historyTableView.dataSource = historyDataSource
        historyTableView.delegate = self
    }

    private func applyProgressSnapshot(items: [ReportProgressItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<ProgressSection, ReportProgressItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        progressDataSource?.apply(snapshot, animatingDifferences: true)
    }

    private func applyHistorySnapshot(reports: [ReportHistoryItem]) {
        let reportsDictionary = Dictionary(grouping: reports) { $0.date }
        let sortedDates = reportsDictionary.keys.sorted(by: >)

        var snapshot = NSDiffableDataSourceSnapshot<String, ReportHistoryItem>()

        for dateKey in sortedDates {
            snapshot.appendSections([dateKey])
            if let items = reportsDictionary[dateKey] {
                snapshot.appendItems(items, toSection: dateKey)
            }
        }

        historyDataSource?.apply(snapshot, animatingDifferences: false)
    }

    private func showCategoryBottomSheet() {
        let categorySelectionView = ReportCategoryTableViewController(reportType: viewModel.selectedReportCategory)
        categorySelectionView.delegate = self
        presentCustomBottomSheet(contentViewController: categorySelectionView, maxHeight: Layout.categoryBottomSheetHeight)
    }
}

extension ReportHistoryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard
            let snapshot = progressDataSource?.snapshot(),
            let item = snapshot.itemIdentifiers[indexPath.item] as? ReportProgressItem
        else { return }

        viewModel.action(input: .filterProgress(progress: item.progress))
    }

}

extension ReportHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: ReportHistoryTableHeaderView.className) as? ReportHistoryTableHeaderView,
            let snapshot = historyDataSource?.snapshot()
        else { return nil }

        guard section < snapshot.sectionIdentifiers.count else { return nil }

        let dateString = snapshot.sectionIdentifiers[section]

        header.configure(with: dateString)

        return header
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let snapshot = historyDataSource?.snapshot()
        else { return }

        let sectionID = snapshot.sectionIdentifiers[indexPath.section]
        let items = snapshot.itemIdentifiers(inSection: sectionID)

        guard indexPath.row < items.count
        else { return }

        let item = items[indexPath.row]

        guard let reportDetailViewModel = DIContainer.shared.resolve(type: ReportDetailViewModel.self)
        else { fatalError("reportDetailViewModel 의존성이 등록되지 않았습니다.") }

        let reportDetailViewController = ReportDetailViewController(viewModel: reportDetailViewModel, reportId: item.id)
        reportDetailViewController.hidesBottomBarWhenPushed = true

        self.navigationController?.pushViewController(reportDetailViewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ReportHistoryViewController: ReportCategoryTableViewControllerDelegate {
    func reportCategoryTableViewController(_ sender: ReportCategoryTableViewController, selectedCategory: ReportType?) {
        guard let selectedCategory = selectedCategory else { return }

        viewModel.action(input: .filterCategory(type: selectedCategory))
    }
}
