//
//  TutorialDetailViewController.swift
//  Presentation
//
//  Created by 최정인 on 9/3/25.
//

import SnapKit
import UIKit

final class TutorialDetailViewController: UIViewController {
    private enum Layout {
        static let horizontalMargin: CGFloat = 24
        static let titleLabelTopSpacing: CGFloat = 26
        static let titleLabelHeight: CGFloat = 24
        static let descriptionLabelTopSpacing: CGFloat = 10
        static let descriptionLabelHeight: CGFloat = 40
        static let tutorialImageTopSpacing: CGFloat = 24
    }

    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let tutorialImage = UIImageView()
    var onDismiss: (() -> Void)?
    private let tutorial: Tutorial

    init(tutorial: Tutorial) {
        self.tutorial = tutorial
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

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onDismiss?()
    }

    private func configureAttribute() {
        view.backgroundColor = BitnagilColor.gray99

        titleLabel.text = tutorial.title
        titleLabel.font = BitnagilFont(style: .title3, weight: .semiBold).font
        titleLabel.textColor = BitnagilColor.gray10

        let descriptionText = tutorial.description
        descriptionLabel.attributedText = BitnagilFont(style: .body2, weight: .medium).attributedString(text: descriptionText)
        descriptionLabel.textColor = BitnagilColor.gray40
        descriptionLabel.numberOfLines = 2

        tutorialImage.image = tutorial.tutorialImage
        tutorialImage.contentMode = .scaleAspectFit
    }

    private func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide

        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(tutorialImage)

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(Layout.titleLabelTopSpacing)
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.height.equalTo(Layout.titleLabelHeight)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Layout.descriptionLabelTopSpacing)
            make.horizontalEdges.equalTo(safeArea).inset(Layout.horizontalMargin)
            make.height.equalTo(Layout.descriptionLabelHeight)
        }

        tutorialImage.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(Layout.tutorialImageTopSpacing)
            make.horizontalEdges.equalTo(safeArea).inset(Layout.horizontalMargin)
            if let image = tutorialImage.image {
                let aspectRatio = image.size.height / image.size.width
                make.height.equalTo(tutorialImage.snp.width).multipliedBy(aspectRatio)
            }
        }
    }
}
