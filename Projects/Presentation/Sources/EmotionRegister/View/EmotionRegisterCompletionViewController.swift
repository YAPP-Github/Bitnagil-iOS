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
        static let speechImageBottomSpacing: CGFloat = 21
        static let speechImageHorizontalSpacing: CGFloat = 54
        static let speechImageHeight: CGFloat = 102
        static let speechLabelTopSpacing: CGFloat = 22
        static let fomoImageWidth: CGFloat = 200
        static let fomoImageHeight: CGFloat = 282
        static let fomoBottomSpacing: CGFloat = 161
    }

    private let backgroundImageView = UIImageView()
    private let speechImageView = UIImageView()
    private let speechLabel = UILabel()
    private let fomoImageView = UIImageView()

    init(emotion: Marble) {
        super.init(nibName: nil, bundle: nil)
        switch emotion {
        case .NONE:
            break
        case .CALM:
            fomoImageView.image = BitnagilGraphic.fomoPurpleGraphic
        case .VITALITY:
            fomoImageView.image = BitnagilGraphic.fomoGreenGraphic
        case .LETHARGY:
            fomoImageView.image = BitnagilGraphic.fogoGrayGraphic
        case .ANXIETY:
            fomoImageView.image = BitnagilGraphic.fomoOrangeGraphic
        case .SATISFACTION:
            fomoImageView.image = BitnagilGraphic.fomomintGraphic
        case .FATIGUE:
            fomoImageView.image = BitnagilGraphic.fomoRedGraphic
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAttribute()
        configureLayout()
    }

    func configureAttribute() {
        backgroundImageView.image = BitnagilGraphic.backgroundGraphic
        speechImageView.image = BitnagilGraphic
            .marbleSpeechGraphic

    }

    func configureLayout() {
        view.addSubview(backgroundImageView)
        view.addSubview(fomoImageView)

        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        fomoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-Layout.fomoBottomSpacing)
            make.width.equalTo(Layout.fomoImageWidth)
            make.height.equalTo(Layout.fomoImageHeight)
        }
    }
}
