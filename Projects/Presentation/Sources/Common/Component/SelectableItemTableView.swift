//
//  SelectableItemTableView.swift
//  Presentation
//
//  Created by 최정인 on 7/24/25.
//

import SnapKit
import UIKit

protocol SelectableItemTableViewDelegate: AnyObject {
    func selectableItemTableView<T: SelectableItem>(_ sender: SelectableItemTableView<T>, didSelectItem: T?)
}

final class SelectableItemTableView<T: SelectableItem & CaseIterable & Equatable>: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let cellHeight: CGFloat = 52
    private let cellHorizontalMargin: CGFloat = 20

    private let itemTableView = UITableView()
    private let items: [T]
    private let markIsSelected: Bool
    private var selectedItem: T? {
        didSet {
            if !markIsSelected && selectedItem == nil { return }
            delegate?.selectableItemTableView(self, didSelectItem: selectedItem)
        }
    }

    weak var delegate: SelectableItemTableViewDelegate?

    init(items: [T], selectedItem: T? = nil, markIsSelected: Bool = true) {
        self.items = items.sorted(by:  { $0.id < $1.id })
        self.selectedItem = selectedItem
        self.markIsSelected = markIsSelected
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAttribute()
        configureLayout()
    }

    private func configureAttribute() {
        itemTableView.delegate = self
        itemTableView.dataSource = self
        itemTableView.register(SelectableItemCell.self, forCellReuseIdentifier: SelectableItemCell.className)
    }

    private func configureLayout() {
        view.addSubview(itemTableView)

        itemTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SelectableItemCell.className, for: indexPath) as? SelectableItemCell
        else { return UITableViewCell() }

        let item = items[indexPath.row]
        let isSelected = selectedItem == item
        cell.configureCell(item: item, isSelected: isSelected)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let isLastCell = indexPath.row == items.count - 1

        if isLastCell {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: cellHorizontalMargin, bottom: 0, right: cellHorizontalMargin)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = items[indexPath.row]
        if self.selectedItem == selectedItem {
            self.selectedItem = nil
        } else {
            self.selectedItem = selectedItem
        }

        if !markIsSelected { self.selectedItem = nil }

        itemTableView.reloadData()
        dismiss(animated: true)
    }
}
