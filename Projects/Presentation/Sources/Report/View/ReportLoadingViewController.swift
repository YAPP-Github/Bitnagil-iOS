//
//  ReportLoadingViewController.swift
//  Presentation
//
//  Created by 최정인 on 11/18/25.
//

import SnapKit
import UIKit

final class ReportLoadingViewController: UIViewController {
    private enum Layout {
        static let loadingImageViewTopSpacing: CGFloat = 78
        static let loadingImageViewSize: CGFloat = 40
        static let loadingLabelTopSpacing: CGFloat = 12
        static let subLabelTopSpacing: CGFloat = 16
        static let fomoImageViewTopSpacing: CGFloat = 58
    }

    private let loadingImageView = UIImageView()
    private let loadingLabel = UILabel()
    private let subLabel = UILabel()
    private let fomoImageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAttribute()
        configureLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            let reportCompleteViewController = ReportCompleteViewController()
            self?.navigationController?.pushViewController(reportCompleteViewController, animated: true)
        }
    }

    private func configureAttribute() {
        view.backgroundColor = .white
        loadingImageView.image = BitnagilIcon.loadingIcon

        loadingLabel.text = "제보 중..."
        loadingLabel.font = BitnagilFont(style: .title2, weight: .bold).font
        loadingLabel.textColor = BitnagilColor.gray10

        subLabel.numberOfLines = 2
        subLabel.attributedText = BitnagilFont(style: .body1, weight: .medium)
            .attributedString(text: "포모가 열심히\n제보하고 있어요!", alignment: .center)
        subLabel.textColor = BitnagilColor.gray40

        fomoImageView.image = BitnagilGraphic.loadingFomoGraphic
    }

    private func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide

        view.addSubview(loadingImageView)
        view.addSubview(loadingLabel)
        view.addSubview(subLabel)
        view.addSubview(fomoImageView)

        loadingImageView.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(Layout.loadingImageViewTopSpacing)
            make.centerX.equalTo(safeArea)
            make.size.equalTo(Layout.loadingImageViewSize)
        }

        loadingLabel.snp.makeConstraints { make in
            make.top.equalTo(loadingImageView.snp.bottom).offset(Layout.loadingLabelTopSpacing)
            make.centerX.equalTo(safeArea)
        }

        subLabel.snp.makeConstraints { make in
            make.top.equalTo(loadingLabel.snp.bottom).offset(Layout.subLabelTopSpacing)
            make.centerX.equalTo(safeArea)
        }

        fomoImageView.snp.makeConstraints { make in
            make.top.equalTo(subLabel.snp.bottom).offset(Layout.fomoImageViewTopSpacing)
            make.centerX.equalTo(safeArea)
        }
    }
}
