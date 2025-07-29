//
//  SplashView.swift
//  Presentation
//
//  Created by 최정인 on 7/27/25.
//

import SnapKit
import UIKit

public final class SplashView: UIViewController {

    private let splashGraphicView = UIImageView()

    override public func viewDidLoad() {
        super.viewDidLoad()
        configureAttribute()
        configureLayout()
    }

    private func configureAttribute() {
        splashGraphicView.image = BitnagilGraphic.introGraphic
    }

    private func configureLayout() {
        view.backgroundColor = .systemBackground
        view.addSubview(splashGraphicView)

        splashGraphicView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
