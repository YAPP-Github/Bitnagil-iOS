//
//  ProgressBarView.swift
//  Presentation
//
//  Created by 최정인 on 7/9/25.
//

import UIKit

final class ProgressBarView: UIView {

    private enum Layout {
        static let maxWidth: CGFloat = 400
        static let barHeight: CGFloat = 5
    }

    private let backgroundView = UIView()
    private let progressView = GradientProgressView()

    init(step: Int, stepCount: Int) {
        super.init(frame: .zero)
        configureAttribute()
        configureLayout(step: step, stepCount: stepCount)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: Layout.maxWidth, height: Layout.barHeight)
    }

    private func configureAttribute() {
        backgroundView.do {
            $0.frame = bounds
            $0.backgroundColor = .white
            $0.layer.cornerRadius = Layout.barHeight / 2
            $0.layer.masksToBounds = true
        }

        progressView.do {
            $0.layer.cornerRadius = Layout.barHeight / 2
            $0.layer.masksToBounds = true
        }
    }

    private func configureLayout(step: Int, stepCount: Int) {
        addSubview(backgroundView)
        addSubview(progressView)

        let progressRatio = min(max(CGFloat(step) / CGFloat(stepCount), 0.0), 1.0)
        backgroundView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }

        progressView.snp.makeConstraints { make in
            make.leading.top.bottom.equalTo(backgroundView)
            make.width.equalTo(backgroundView).multipliedBy(progressRatio)
        }
    }
}
