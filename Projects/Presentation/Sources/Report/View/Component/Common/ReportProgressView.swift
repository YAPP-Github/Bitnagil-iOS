//
//  ReportProgressView.swift
//  Presentation
//
//  Created by 이동현 on 11/20/25.
//

import Domain
import SnapKit
import UIKit

final class ReportProgressView: UIView {

    private enum Layout {
        static let progressViewHeight: CGFloat = 26
        static let progressLabelHeight: CGFloat = 18
        static let progressLabelHorizontalSpacing: CGFloat = 10
        static let progressLabelVerticalSpacing: CGFloat = 4
    }

    private let progressLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        layer.cornerRadius = 6
        layer.masksToBounds = true

        progressLabel.font = BitnagilFont.init(style: .caption1, weight: .semiBold).font
    }

    private func configureLayout() {
        addSubview(progressLabel)

        self.snp.makeConstraints { make in
            make.height.equalTo(Layout.progressViewHeight)
        }

        progressLabel.snp.makeConstraints { make in
            make.height.equalTo(Layout.progressLabelHeight)

            make.verticalEdges
                .equalToSuperview()
                .inset(Layout.progressLabelVerticalSpacing)

            make.horizontalEdges
                .equalToSuperview()
                .inset(Layout.progressLabelHorizontalSpacing)
        }
    }

    func configure(with progress: ReportProgress) {
        backgroundColor = progress.backgroundColor

        progressLabel.textColor = progress.titleColor
        progressLabel.text = progress.description
    }
}
