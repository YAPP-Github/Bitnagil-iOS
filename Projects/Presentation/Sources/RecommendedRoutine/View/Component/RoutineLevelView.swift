//
//  RoutineLevelView.swift
//  Presentation
//
//  Created by 최정인 on 7/14/25.
//

import UIKit

protocol RoutineLevelViewDelegate: AnyObject {
    func routineLevelViewDelegate(_ sender: RoutineLevelView, didSelectLevel: RoutineLevelType?)
}

public final class RoutineLevelView: UIViewController {

    private enum Layout {
        static let cellHeight: CGFloat = 52
    }

    private let levelTableView = UITableView()
    private var selectedLevel: RoutineLevelType? = nil {
        didSet {
            levelTableView.reloadData()
            delegate?.routineLevelViewDelegate(self, didSelectLevel: selectedLevel)
        }
    }
    weak var delegate: RoutineLevelViewDelegate?

    public override func viewDidLoad() {
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
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RoutineLevelType.allCases.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RoutineLevelCell", for: indexPath) as? RoutineLevelCell
        else { return UITableViewCell() }
        let level = RoutineLevelType.allCases.sorted(by: { $0.id < $1.id })[indexPath.row]

        let isSelected = selectedLevel == level
        cell.configureCell(level: level, isSelected: isSelected)
        return cell
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Layout.cellHeight
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLevel = RoutineLevelType.allCases.sorted(by: { $0.id < $1.id })[indexPath.row]
        if self.selectedLevel == selectedLevel {
            self.selectedLevel = nil
        } else {
            self.selectedLevel = selectedLevel
        }
        dismiss(animated: true)
    }
}
