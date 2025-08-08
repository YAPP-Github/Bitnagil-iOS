//
//  SplashView.swift
//  Presentation
//
//  Created by 최정인 on 7/27/25.
//

import Lottie
import SnapKit
import UIKit

public protocol SplashViewDelegate: AnyObject {
    func splashView(_ sender: SplashView, isCompletedAnimated: Bool)
}

public final class SplashView: UIViewController {

    private enum Layout {
        static let splashAnimationViewVerticalOffset: CGFloat = -20
        static let splashAnimationViewSize: CGFloat = 205
        static let logoImageTopSpacing: CGFloat = -10
    }

    private var splashAnimationView = LottieAnimationView()
    private let logoImage = UIImageView()
    public weak var delegate: SplashViewDelegate?

    override public func viewDidLoad() {
        super.viewDidLoad()
        configureAttribute()
        configureLayout()
        splashAnimationView.play { [weak self] completed in
            guard let self else { return }
            self.delegate?.splashView(self, isCompletedAnimated: completed)
        }
    }

    private func configureAttribute() {
        let presentationBundle = Bundle(for: SplashView.self)
        guard let filePath = presentationBundle.path(forResource: "splash", ofType: "json")
        else { return }
        splashAnimationView =  LottieAnimationView(filePath: filePath)
        splashAnimationView.contentMode = .scaleAspectFit
        splashAnimationView.loopMode = .playOnce

        logoImage.image = BitnagilGraphic.logoGraphic
        logoImage.contentMode = .scaleAspectFit
    }

    private func configureLayout() {
        view.backgroundColor = .white
        view.addSubview(splashAnimationView)
        view.addSubview(logoImage)

        splashAnimationView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(Layout.splashAnimationViewVerticalOffset)
            make.size.equalTo(Layout.splashAnimationViewSize)
        }

        logoImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(splashAnimationView.snp.bottom).offset(Layout.logoImageTopSpacing)
        }
    }
}
