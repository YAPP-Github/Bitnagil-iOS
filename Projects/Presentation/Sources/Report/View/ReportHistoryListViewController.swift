//
//  ReportHistoryViewController.swift
//  Presentation
//
//  Created by 이동현 on 11/15/25.
//

import Combine
import SnapKit
import UIKit

final class ReportHistoryListViewController: BaseViewController<ReportListHistoryViewModel> {
    private enum Layout {
        static let horizontalSpacing: CGFloat = 20
        static let progressCollectionViewTopSpacing: CGFloat = 70
        static let progressCollectionViewHeight: CGFloat = 36
        static let progressCellSpacing: CGFloat = 8
        static let historyTableViewTopSpacing: CGFloat = 34
        static let historyTableViewSectionSpacing: CGFloat = 34
        static let historyCellSpacing: CGFloat = 10
        static let categoryButtonLabelHeight: CGFloat = 20
        static let categoryButtonLabelWidth: CGFloat = 52
        static let categoryButtonTopSpacing: CGFloat = 2
        static let categoryButtonImageSize: CGFloat = 16
        static let categoryButtonImageLeadingSpacing: CGFloat = 5
        static let cetegoryButtonHeight: CGFloat = 40
    }

    private let progressCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    private let categoryLabel = UILabel()
    private let categoryButtonImage = UIImageView()
    private let categoryButton = UIButton()
    private let historyTableView = UITableView(frame: .zero, style: .grouped)
    private var cancellables: Set<AnyCancellable> = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureCustomNavigationBar(navigationBarStyle: .withBackButton(title: "내 제보 기록"))
    }

    override func configureAttribute() {
        categoryButton.backgroundColor = .clear
    }

    override func configureLayout() {
        view.addSubview(progressCollectionView)
        view.addSubview(historyTableView)
        view.addSubview(categoryLabel)
        view.addSubview(categoryButtonImage)
        view.addSubview(categoryButton)

        progressCollectionView.snp.makeConstraints { make in
            make.top
                .equalToSuperview()
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

            make.trailing
                .equalToSuperview()
                .offset(-Layout.horizontalSpacing)

            make.height.equalTo(Layout.cetegoryButtonHeight)
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
            .sink(receiveValue: { selectedCategory in

            })
            .store(in: &cancellables)

        viewModel.output.progressPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { progresses in

            })
            .store(in: &cancellables)

        viewModel.output.selectedProgressPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { selectedProgress in

            })
            .store(in: &cancellables)

        viewModel.output.reportsPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { reports in

            })
            .store(in: &cancellables)

        viewModel.output.selectedReportPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { selectedReport in

            })
            .store(in: &cancellables)
    }
}
