//
//  UIViewController+.swift
//  Presentation
//
//  Created by 최정인 on 7/8/25.
//

import UIKit

extension UIViewController {

    func configureNavigationBar(navigationStyle: NavigationBarStyle) {
        switch navigationStyle {
        case .hidden:
            navigationController?.setNavigationBarHidden(true, animated: false)

        case .withBackButton(let title):
            navigationController?.setNavigationBarHidden(false, animated: false)
            self.title = title
            configureDefaultBackButton()

        case .withPrograssBar(let step, let stepCount):
            navigationController?.setNavigationBarHidden(false, animated: false)
            configureDefaultBackButton()
            configureProgressNavigationBar(step: step, stepCount: stepCount)

        case .withPrograssBarWithCustomBackButton(let step, let stepCount):
            navigationController?.setNavigationBarHidden(false, animated: false)
            configureCustomBackButton()
            configureProgressNavigationBar(step: step, stepCount: stepCount)
        }
    }

    private func configureDefaultBackButton() {
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(popViewController))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
    }

    private func configureCustomBackButton() {
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(popTwoViewControllers))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
    }

    private func configureProgressNavigationBar(step: Int, stepCount: Int) {
        self.title = ""
        let progressView = ProgressBarView(step: step, stepCount: stepCount)
        navigationItem.titleView = progressView
    }

    @objc private func popViewController() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func popTwoViewControllers() {
        guard let navigationController = navigationController else { return }
        let viewControllers = navigationController.viewControllers

        guard viewControllers.count >= 3 else {
            navigationController.popViewController(animated: true)
            return
        }

        let targetViewController = viewControllers[viewControllers.count - 3]
        navigationController.popToViewController(targetViewController, animated: true)
    }
}

enum NavigationBarStyle {
    case hidden
    case withBackButton(title: String)
    case withPrograssBar(step: Int, stepCount: Int)
    case withPrograssBarWithCustomBackButton(step: Int, stepCount: Int)
}
