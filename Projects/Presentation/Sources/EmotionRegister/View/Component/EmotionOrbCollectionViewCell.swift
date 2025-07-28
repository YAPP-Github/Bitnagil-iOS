//
//  EmotionOrbCollectionViewCell.swift
//  Presentation
//
//  Created by 최정인 on 7/28/25.
//

import SnapKit
import UIKit

final class EmotionOrbCollectionViewCell: UICollectionViewCell {

    private enum Layout {
        static let emotionOrbImageSize: CGFloat = 96
        static let emotionLabelTopSpacing: CGFloat = 6
        static let emotionLabelHeight: CGFloat = 24
    }

    private let emotionOrbImage = UIImageView()
    private let emotionLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        emotionLabel.text = ""
        emotionLabel.textAlignment = .center
        emotionLabel.font = BitnagilFont(style: .body1, weight: .regular).font
        emotionLabel.textColor = BitnagilColor.gray20
    }

    private func configureLayout() {
        contentView.addSubview(emotionOrbImage)
        contentView.addSubview(emotionLabel)

        emotionOrbImage.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.size.equalTo(Layout.emotionOrbImageSize)
        }

        emotionLabel.snp.makeConstraints { make in
            make.top.equalTo(emotionOrbImage.snp.bottom).offset(Layout.emotionLabelTopSpacing)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(Layout.emotionLabelHeight)
        }
    }

    func configureCell(emotion: EmotionType) {
        emotionOrbImage.image = emotion.image
        emotionLabel.text = emotion.title
    }
}
