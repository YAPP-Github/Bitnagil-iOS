//
//  TutorialViewController.swift
//  Presentation
//
//  Created by 최정인 on 9/3/25.
//

import SnapKit
import UIKit

final class TutorialViewController: UIViewController {
    private enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let tutorialTableViewTopSpacing: CGFloat = 86
        static let tutorialTableViewCellHeight: CGFloat = 56
        static let tutorialTableViewCellSpacing: CGFloat = 12
    }

    private let tutorialTableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAttribute()
        configureLayout()
    }

    private func configureAttribute() {
        tutorialTableView.delegate = self
        tutorialTableView.dataSource = self

        tutorialTableView.register(TutorialTableCell.self, forCellReuseIdentifier: TutorialTableCell.className)
        tutorialTableView.separatorStyle = .none
        tutorialTableView.isScrollEnabled = false
    }

    private func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        view.backgroundColor = .systemBackground
        navigationController?.setNavigationBarHidden(true, animated: false)
        configureCustomNavigationBar(navigationBarStyle: .withBackButton(title: "설명서"))

        view.addSubview(tutorialTableView)
        tutorialTableView.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(Layout.tutorialTableViewTopSpacing)
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.trailing.equalTo(safeArea).offset(-Layout.horizontalMargin)
            make.bottom.equalTo(safeArea)
        }
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension TutorialViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Tutorial.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TutorialTableCell.className, for: indexPath) as? TutorialTableCell
        else { return UITableViewCell() }

        let tutorial = Tutorial.allCases[indexPath.section]
        cell.configure(title: tutorial.title)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Layout.tutorialTableViewCellHeight
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return Layout.tutorialTableViewCellSpacing
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}
