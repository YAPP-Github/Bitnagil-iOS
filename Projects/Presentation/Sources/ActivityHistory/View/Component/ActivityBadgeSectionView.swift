//
//  ActivityBadgeSectionView.swift
//  Presentation
//
//  Created by 최정인 on 7/7/26.
//

import Kingfisher
import SnapKit
import UIKit

final class ActivityBadgeSectionView: UIView {
    private enum Layout {
        static let badgeStackViewSpacing: CGFloat = 12
        static let badgeImageSingleSize: CGFloat = 125
        static let badgeImagemultipleSize: CGFloat = 100
        static let badgeExpertViewHeight: CGFloat = 34
        static let badgeExpertViewWidth: CGFloat = 101
    }

    private let badgeStackView = UIStackView()
    private let badgeTitleLabel = UILabel()
    private let badgeImageStackView = UIStackView()
    private let badgeExpertView = ActivityBadgeExpertComponentView()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        badgeStackView.axis = .vertical
        badgeStackView.alignment = .center
        badgeStackView.spacing = Layout.badgeStackViewSpacing

        badgeTitleLabel.attributedText = BitnagilFont(
            family: .cafe24Ssurround,
            style: .cafe24Title1,
            weight: .light).attributedString(text: " ")
        badgeTitleLabel.textAlignment = .center
        badgeTitleLabel.numberOfLines = 2
        badgeTitleLabel.textColor = .white

        badgeImageStackView.axis = .horizontal
        badgeImageStackView.alignment = .center
        badgeImageStackView.distribution = .equalSpacing
        badgeImageStackView.spacing = 0
    }

    private func configureLayout() {
        addSubview(badgeStackView)
        [badgeTitleLabel, badgeImageStackView, badgeExpertView].forEach {
            badgeStackView.addArrangedSubview($0)
        }

        badgeStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        badgeExpertView.snp.makeConstraints { make in
            make.height.equalTo(Layout.badgeExpertViewHeight)
            make.width.greaterThanOrEqualTo(Layout.badgeExpertViewWidth)
        }
    }

    func configureBadge(badge: ActivityBadge) {
        badgeTitleLabel.text = badge.description
        badgeExpertView.configure(expertTitle: badge.title)

        badgeImageStackView.arrangedSubviews.forEach {
            badgeImageStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let badgeImageSize: CGFloat = badge.imageUrls.count > 1 ? Layout.badgeImagemultipleSize : Layout.badgeImageSingleSize
        badge.imageUrls.forEach { imageURL in
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit

            if let url = URL(string: imageURL) {
                imageView.kf.setImage(with: url)
            }
            imageView.snp.makeConstraints { make in
                make.size.equalTo(badgeImageSize)
            }
            badgeImageStackView.addArrangedSubview(imageView)
        }
    }
}
