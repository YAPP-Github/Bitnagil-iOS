//
//  RoutineLevelView.swift
//  Presentation
//
//  Created by 최정인 on 7/14/25.
//

import UIKit

protocol RoutineLevelViewDelegate: AnyObject {
    func routineLevelView(_ sender: RoutineLevelView, didSelectLevel: RoutineLevelType?)
}

final class RoutineLevelView: UIViewController {

    private enum Layout {
        static let cellHeight: CGFloat = 52
        static let cellHorizontalMargin: CGFloat = 20
    }

    private let levelTableView = UITableView()
    private let sortedRoutineLevels = RoutineLevelType.allCases.sorted(by: { $0.id < $1.id })
    private var selectedLevel: RoutineLevelType? {
        didSet {
            delegate?.routineLevelView(self, didSelectLevel: selectedLevel)
        }
    }
    weak var delegate: RoutineLevelViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAttribute()
        configureLayout()
    }

    private func configureAttribute() {
        levelTableView.delegate = self
        levelTableView.dataSource = self
        levelTableView.register(RoutineLevelCell.self, forCellReuseIdentifier: "RoutineLevelCell")
    }

    private func configureLayout() {
        view.addSubview(levelTableView)

        levelTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension RoutineLevelView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedRoutineLevels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RoutineLevelCell", for: indexPath) as? RoutineLevelCell
        else { return UITableViewCell() }
        let level = sortedRoutineLevels[indexPath.row]

        let isSelected = selectedLevel == level
        cell.configureCell(level: level, isSelected: isSelected)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Layout.cellHeight
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let isLastCell = indexPath.row == RoutineLevelType.allCases.count - 1

        if isLastCell {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: Layout.cellHorizontalMargin, bottom: 0, right: Layout.cellHorizontalMargin)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLevel = RoutineLevelType.allCases.sorted(by: { $0.id < $1.id })[indexPath.row]
        if self.selectedLevel == selectedLevel {
            self.selectedLevel = nil
        } else {
            self.selectedLevel = selectedLevel
        }
        levelTableView.reloadData()
        dismiss(animated: true)
    }
}
