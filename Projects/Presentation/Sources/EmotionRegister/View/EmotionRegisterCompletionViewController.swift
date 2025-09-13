//
//  EmotionRegisterCompletionViewController.swift
//  Presentation
//
//  Created by 이동현 on 8/23/25.
//

import SnapKit
import UIKit

final class EmotionRegisterCompletionViewController: UIViewController {
    private enum Layout {
        static let speechImageHorizontalSpacing: CGFloat = 54
        static let speechImageHeight: CGFloat = 102
        static let speechImageBottomSpacing: CGFloat = 24
        static let speechLabelHorizontalSpacing: CGFloat = 20
        static let speechLabelTopSpacing: CGFloat = 22
        static let groundImageHeight: CGFloat = 171
        static let pomoImageWidth: CGFloat = 200
        static let pomoImageHeight: CGFloat = 282
        static let pomoBottomSpacing: CGFloat = 10
        static let pomoLeftHandImageHeight: CGFloat = 52.98
        static let pomoLeftHandImageWidth: CGFloat = 48.51
        static let pomoLeftHandLeadingSpacing: CGFloat = 17.71
        static let pomoRightHandImageHeight: CGFloat = 52.89
        static let pomoRightHandImageWidth: CGFloat = 48.91
        static let pomoRightHandTrailingSpacing: CGFloat = 16.65
        static let pomoHandImageTopSpacing: CGFloat = 116.77
        static let marbleImageSize: CGFloat = 120
        static let marbleImageTopSpacing: CGFloat = 96.92
    }

    private let backgroundImageView = UIImageView()
    private let groundImageView = UIImageView()
    private let speechImageView = UIImageView()
    private let speechLabel = UILabel()
    private let pomoImageView = UIImageView()
    private let marbleImageView = UIImageView()
    private let pomoLeftHandImageView = UIImageView()
    private let pomoRightHandImageView = UIImageView()

    init(emotion: Emotion) {
        super.init(nibName: nil, bundle: nil)

        marbleImageView.image = emotion.image
        speechLabel.text = """
                           \(emotion.titleDescription ?? "") 하루에 맞춰
                           루틴을 추천해드릴게요!
                           """
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAttribute()
        configureLayout()

        // TODO: - 임시 네비 바 설정
        configureCustomNavigationBar(navigationBarStyle: .withBackButton(title: "임시뒤로가기"))
        let filteredNavigations = navigationController?.viewControllers.filter { !($0 is EmotionRegistrationViewController) } ?? []
        navigationController?.setViewControllers(filteredNavigations, animated: false)
    }

    func configureAttribute() {
        backgroundImageView.image = BitnagilGraphic.emotionCompletionBackgroundGraphic
        groundImageView.image = BitnagilGraphic.emotionCompletionGroundGraphic
        pomoImageView.image = BitnagilGraphic.marblePomoGraphic
        pomoLeftHandImageView.image = BitnagilGraphic.pomoLeftHandGraphic
        pomoRightHandImageView.image = BitnagilGraphic.pomoRightHandGraphic

        speechImageView.image = BitnagilGraphic.marbleSpeechGraphic?.withRenderingMode(.alwaysTemplate)
        speechImageView.tintColor = BitnagilColor.gray10
        speechLabel.font = BitnagilFont.init(style: .cafe24Title2, weight: .light).font
        speechLabel.numberOfLines = 2
        speechLabel.textColor = .white
        speechLabel.textAlignment = .center
    }

    func configureLayout() {
        view.addSubview(backgroundImageView)
        view.addSubview(groundImageView)
        view.addSubview(pomoImageView)
        view.addSubview(marbleImageView)
        view.addSubview(pomoLeftHandImageView)
        view.addSubview(pomoRightHandImageView)
        view.addSubview(speechImageView)
        view.addSubview(speechLabel)

        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        groundImageView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview()
            make.height.equalTo(Layout.groundImageHeight)
        }

        pomoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(groundImageView.snp.top).offset(Layout.pomoBottomSpacing)
            make.width.equalTo(Layout.pomoImageWidth)
            make.height.equalTo(Layout.pomoImageHeight)
        }

        marbleImageView.snp.makeConstraints { make in
            make.top.equalTo(pomoImageView.snp.top).offset(Layout.marbleImageTopSpacing)
            make.centerX.equalTo(pomoImageView)
            make.size.equalTo(Layout.marbleImageSize)
        }

        pomoLeftHandImageView.snp.makeConstraints { make in
            make.top.equalTo(pomoImageView.snp.top).offset(Layout.pomoHandImageTopSpacing)
            make.leading.equalTo(pomoImageView).offset(Layout.pomoLeftHandLeadingSpacing)
            make.height.equalTo(Layout.pomoLeftHandImageHeight)
            make.width.equalTo(Layout.pomoLeftHandImageWidth)
        }

        pomoRightHandImageView.snp.makeConstraints { make in
            make.top.equalTo(pomoImageView.snp.top).offset(Layout.pomoHandImageTopSpacing)
            make.trailing.equalTo(pomoImageView).offset(-Layout.pomoRightHandTrailingSpacing)
            make.width.equalTo(Layout.pomoRightHandImageWidth)
            make.height.equalTo(Layout.pomoRightHandImageHeight)
        }

        speechImageView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(Layout.speechImageHorizontalSpacing)
            make.height.equalTo(Layout.speechImageHeight)
            make.bottom.equalTo(pomoImageView.snp.top).offset(-Layout.speechImageBottomSpacing)
        }

        speechLabel.snp.makeConstraints { make in
            make.top.equalTo(speechImageView.snp.top).offset(Layout.speechLabelTopSpacing)
            make.horizontalEdges.equalTo(speechImageView).inset(Layout.speechImageHorizontalSpacing)
        }
    }
}
