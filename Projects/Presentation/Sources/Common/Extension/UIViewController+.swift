//
//  UIViewController+.swift
//  Presentation
//
//  Created by 최정인 on 7/8/25.
//

import SnapKit
import UIKit

extension UIViewController {
    // MARK: - NavigationBar
    enum NavigationBarStyle {
        case withBackButton(title: String)  // 백버튼 + 타이틀 (없으면 빈 String)
        case withTitle(title: String)       // 오로지 타이틀만
        case withProgressBar(step: Int)     // 백버튼 + progress
    }

    func configureCustomNavigationBar(navigationBarStyle: NavigationBarStyle, backgroundColor: UIColor? = .white) {
        let safeArea = self.view.safeAreaLayoutGuide
        let navigationBar: UIView = customNavigationBar(navigationBarStyle: navigationBarStyle)

        navigationBar.backgroundColor = backgroundColor
        self.view.addSubview(navigationBar)
        navigationBar.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeArea)
            make.height.equalTo(48)
        }
    }

    private func customNavigationBar(navigationBarStyle: NavigationBarStyle) -> UIView {
        let navigationBar = UIView()
        let customBackButton = UIButton()
        let titleLabel = UILabel()
        let progressView = UIImageView()

        customBackButton.setImage(BitnagilIcon.backButtonIcon, for: .normal)
        customBackButton.addAction(
            UIAction { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            },
            for: .touchUpInside)

        titleLabel.text = " "
        titleLabel.font = BitnagilFont(style: .title3, weight: .semiBold).font
        titleLabel.textColor = BitnagilColor.gray10

        progressView.isHidden = true

        switch navigationBarStyle {
        case .withBackButton(let title):
            titleLabel.text = title

        case .withTitle(let title):
            titleLabel.text = title
            customBackButton.isHidden = true

        case .withProgressBar(let step):
            titleLabel.isHidden = true
            progressView.image = progressImage(step: step)
            progressView.isHidden = false
        }

        navigationBar.backgroundColor = .systemBackground
        [customBackButton, titleLabel, progressView].forEach {
            navigationBar.addSubview($0)
        }

        customBackButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.size.equalTo(48)
        }

        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        progressView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        return navigationBar
    }

    private func progressImage(step: Int) -> UIImage? {
        switch step {
        case 1: BitnagilGraphic.progressStep1
        case 2: BitnagilGraphic.progressStep2
        case 3: BitnagilGraphic.progressStep3
        case 4: BitnagilGraphic.progressStep4
        case 5: BitnagilGraphic.progressStep5
        default: nil
        }
    }

    // MARK: - BottomSheet
    func presentCustomBottomSheet(contentViewController: UIViewController, maxHeight: CGFloat) {
        let bottomSheet = CustomBottomSheet(contentViewController: contentViewController, maxHeight: maxHeight)
        present(bottomSheet, animated: true)
    }
}
