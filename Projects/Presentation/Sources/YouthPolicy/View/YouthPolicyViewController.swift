//
//  YouthPolicyViewController.swift
//  Presentation
//
//  Created by 이동현 on 7/19/26.
//

import Combine
import SnapKit
import UIKit

final class YouthPolicyViewController: BaseViewController<YouthPolicyViewModel> {
    private enum Layout {
        static let horizontalSpacing: CGFloat = 20
        static let tabCollectionViewTopSpacing: CGFloat = 80
        static let tabCollectionViewHeight: CGFloat = 36
        static let tabCollectionViewWidth: CGFloat = 48
        static let tabCellSpacing: CGFloat = 8
        static let policyTableViewTopSpacing: CGFloat = 34
        static let policyTableViewCellHeight: CGFloat = 122
        static let emptyViewHeight: CGFloat = 50
        static let emptyViewWidth: CGFloat = 269
    }

    private enum TabSection {
        case main
    }

    private enum PolicySection {
        case main
    }

    private let tabCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    private let policyTableView = UITableView(frame: .zero, style: .plain)
    private let policyEmptyView = YouthPolicyEmptyView()
    private var tabDataSource: UICollectionViewDiffableDataSource<TabSection, YouthPolicyTabItem>?
    private var policyDataSource: UITableViewDiffableDataSource<PolicySection, YouthPolicyItem>?
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.action(input: .fetchPolicies)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        configureCustomNavigationBar(
            navigationBarStyle: .withBackButton(title: "청년 공고"),
            backgroundColor: BitnagilColor.gray99)
    }

    override func configureAttribute() {
        super.configureAttribute()

        view.backgroundColor = BitnagilColor.gray99

        policyEmptyView.isHidden = true

        configureTabCollectionView()
        configurePolicyTableView()
    }

    override func configureLayout() {
        super.configureLayout()
        let safeArea = view.safeAreaLayoutGuide

        view.addSubview(tabCollectionView)
        view.addSubview(policyTableView)
        view.addSubview(policyEmptyView)

        tabCollectionView.snp.makeConstraints { make in
            make.top
                .equalTo(safeArea.snp.top)
                .offset(Layout.tabCollectionViewTopSpacing)

            make.horizontalEdges
                .equalToSuperview()
                .inset(Layout.horizontalSpacing)

            make.height.equalTo(Layout.tabCollectionViewHeight)
        }

        policyTableView.snp.makeConstraints { make in
            make.horizontalEdges
                .equalToSuperview()
                .inset(Layout.horizontalSpacing)

            make.top
                .equalTo(tabCollectionView.snp.bottom)
                .offset(Layout.policyTableViewTopSpacing)

            make.bottom.equalToSuperview()
        }

        policyEmptyView.snp.makeConstraints { make in
            make.center.equalToSuperview()

            make.width.equalTo(Layout.emptyViewWidth)

            make.height.equalTo(Layout.emptyViewHeight)
        }
    }

    override func bind() {
        viewModel.output.tabsPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] tabs in
                self?.applyTabSnapshot(items: tabs)
            })
            .store(in: &cancellables)

        viewModel.output.policiesPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] policies in
                self?.applyPolicySnapshot(policies: policies)
            })
            .store(in: &cancellables)

        viewModel.output.isEmptyPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isEmpty in
                guard let self else { return }

                self.policyEmptyView.configure(with: self.viewModel.selectedTab)
                self.policyEmptyView.isHidden = !isEmpty
            })
            .store(in: &cancellables)

        bindNetworkError(from: viewModel.output.networkErrorPublisher)
    }

    private func configureTabCollectionView() {
        tabCollectionView.backgroundColor = .clear
        tabCollectionView.bounces = false
        tabCollectionView.showsHorizontalScrollIndicator = false

        tabCollectionView.setCollectionViewLayout(createTabLayout(), animated: false)

        tabCollectionView.register(
            YouthPolicyTabCollectionViewCell.self,
            forCellWithReuseIdentifier: YouthPolicyTabCollectionViewCell.className)

        tabDataSource = UICollectionViewDiffableDataSource<TabSection, YouthPolicyTabItem>(collectionView: tabCollectionView) { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: YouthPolicyTabCollectionViewCell.className,
                for: indexPath) as? YouthPolicyTabCollectionViewCell
            else { return UICollectionViewCell() }

            cell.configure(with: item)
            return cell
        }

        tabCollectionView.delegate = self
    }

    private func createTabLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .estimated(Layout.tabCollectionViewWidth),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .estimated(Layout.tabCollectionViewWidth),
            heightDimension: .fractionalHeight(1.0)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(Layout.tabCellSpacing)

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = Layout.tabCellSpacing
        section.contentInsets = .zero

        return UICollectionViewCompositionalLayout(section: section)
    }

    private func configurePolicyTableView() {
        policyTableView.backgroundColor = .clear
        policyTableView.separatorStyle = .none
        policyTableView.showsVerticalScrollIndicator = false
        policyTableView.rowHeight = UITableView.automaticDimension
        policyTableView.estimatedRowHeight = Layout.policyTableViewCellHeight
        policyTableView.sectionHeaderTopPadding = CGFloat.zero
        policyTableView.sectionHeaderHeight = CGFloat.zero
        policyTableView.sectionFooterHeight = CGFloat.zero
        policyTableView.estimatedSectionHeaderHeight = CGFloat.zero
        policyTableView.estimatedSectionFooterHeight = CGFloat.zero
        policyTableView.contentInset = .zero

        policyTableView.register(
            YouthPolicyTableViewCell.self,
            forCellReuseIdentifier: YouthPolicyTableViewCell.className)

        policyDataSource = UITableViewDiffableDataSource<PolicySection, YouthPolicyItem>(tableView: policyTableView) { [weak self] tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: YouthPolicyTableViewCell.className,
                for: indexPath) as? YouthPolicyTableViewCell
            else { return UITableViewCell() }

            cell.configure(with: item) { [weak self] in
                self?.viewModel.action(input: .toggleBookmark(policyNumber: item.policyNumber))
            }

            return cell
        }

        policyTableView.dataSource = policyDataSource
        policyTableView.delegate = self
    }

    private func applyTabSnapshot(items: [YouthPolicyTabItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<TabSection, YouthPolicyTabItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        tabDataSource?.apply(snapshot, animatingDifferences: false)
    }

    private func applyPolicySnapshot(policies: [YouthPolicyItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<PolicySection, YouthPolicyItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(policies, toSection: .main)
        policyDataSource?.apply(snapshot, animatingDifferences: false)
    }
}

extension YouthPolicyViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard
            let snapshot = tabDataSource?.snapshot(),
            indexPath.item < snapshot.itemIdentifiers.count
        else { return }

        let item = snapshot.itemIdentifiers[indexPath.item]

        viewModel.action(input: .selectTab(tab: item.tab))
    }
}

extension YouthPolicyViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { tableView.deselectRow(at: indexPath, animated: true) }

        guard
            let item = policyDataSource?.itemIdentifier(for: indexPath),
            let applyURL = item.applyURL,
            UIApplication.shared.canOpenURL(applyURL)
        else { return }

        UIApplication.shared.open(applyURL)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard
            let snapshot = policyDataSource?.snapshot(),
            indexPath.row == snapshot.numberOfItems - 1
        else { return }

        viewModel.action(input: .loadNextPage)
    }
}
