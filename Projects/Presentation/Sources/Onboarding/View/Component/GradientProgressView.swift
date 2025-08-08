//
//  GradientProgressView.swift
//  Presentation
//
//  Created by 최정인 on 7/9/25.
//

import UIKit

final class GradientProgressView: UIView {

    private let barHeight: CGFloat = 5
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureGradient()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureGradient() {
        gradientLayer.colors = [
            BitnagilColor.gradientLeft?.cgColor ?? UIColor.blue.cgColor,
            BitnagilColor.gradientRight?.cgColor ?? UIColor.red.cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = barHeight / 2
        layer.addSublayer(gradientLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
