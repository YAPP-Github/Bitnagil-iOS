//
//  EmotionCollectionViewCell.swift
//  Presentation
//
//  Created by 이동현 on 8/19/25.
//

import SnapKit
import UIKit

final class EmotionCollectionViewCell: UICollectionViewCell {
    private enum Layout {
        static let imageViewSize: CGFloat = 120
        static let maxImageViewSize: CGFloat = 140
        static let maxTranslateY: CGFloat = 51
    }

    private let emotionImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureAttribute()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.transform = .identity
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)

        guard let attributes = layoutAttributes as? EmotionCollectionViewLayoutAttributes else { return }

        let progress = attributes.progress
        let targetScale = Layout.maxImageViewSize / Layout.imageViewSize
        let scale = 1.0 + (targetScale - 1.0) * progress
        let translateY = Layout.maxTranslateY * progress
        let transform = CGAffineTransform.identity
                    .scaledBy(x: scale, y: scale)
                    .translatedBy(x: 0, y: translateY)

        emotionImageView.transform = transform
    }

    func configure(image: UIImage?) {
        emotionImageView.image = image
    }

    private func configureAttribute() {
        emotionImageView.layer.cornerRadius = Layout.imageViewSize / 2
        emotionImageView.layer.masksToBounds = true
    }

    private func configureLayout() {
        contentView.addSubview(emotionImageView)

        emotionImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(Layout.imageViewSize)
        }
    }
}
