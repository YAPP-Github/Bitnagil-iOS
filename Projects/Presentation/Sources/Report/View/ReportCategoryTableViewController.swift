//
//  ReportCategoryTableView.swift
//  Presentation
//
//  Created by 이동현 on 11/15/25.
//

import Domain
import SnapKit
import UIKit

protocol ReportCategoryTableViewControllerDelegate: AnyObject {
    func reportCategoryTableViewController(_ sender: ReportCategoryTableViewController, selectedCategory: ReportType?)
}

final class ReportCategoryTableViewController: UIViewController {
    private enum Layout {
        static let tableViewTopSpacing: CGFloat = 14
        static let tableViewHorizontalSpacing: CGFloat = 20
        static let tableViewCellHeight: CGFloat = 72
    }

    private let categoryTableView = UITableView(frame: .zero, style: .plain)
    private var selectedCategory: ReportType?
    weak var delegate: ReportCategoryTableViewControllerDelegate?

    init(reportType: ReportType?) {
        super.init(nibName: nil, bundle: nil)
        configureAttribute()
        configureLayout()

        selectedCategory = reportType
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        categoryTableView.register(ReportCategoryTableViewCell.self, forCellReuseIdentifier: ReportCategoryTableViewCell.className)
        categoryTableView.showsVerticalScrollIndicator = false
    }

    private func configureLayout() {
        view.addSubview(categoryTableView)

        categoryTableView.snp.makeConstraints { make in
            make.top
                .equalToSuperview()
                .offset(Layout.tableViewTopSpacing)

            make.bottom.equalToSuperview()

            make.horizontalEdges
                .equalToSuperview()
                .inset(Layout.tableViewHorizontalSpacing)
        }
    }
}

extension ReportCategoryTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Layout.tableViewCellHeight
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ReportType.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReportCategoryTableViewCell.className, for: indexPath) as? ReportCategoryTableViewCell else { return UITableViewCell() }

        let reportType = ReportType.allCases[indexPath.row]
        let isSelected = selectedCategory == reportType

        cell.configureCell(reportType: reportType, isSelected: isSelected)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedReportType = ReportType.allCases[indexPath.row]

        delegate?.reportCategoryTableViewController(self, selectedCategory: selectedReportType)

        dismiss(animated: true)
    }
}
