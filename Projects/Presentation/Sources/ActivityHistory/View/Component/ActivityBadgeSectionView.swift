//
//  ActivityBadgeSectionView.swift
//  Presentation
//
//  Created by 최정인 on 7/7/26.
//

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

    func configureBadge(badges: [ActivityBadge]) {
        var badgeImages: [UIImage?] = []
        switch badges.count {
        case 0:
            badgeTitleLabel.text = "오늘, 작은 변화를\n만들어볼까요?"
            badgeExpertView.configure(expertTitle: "예비 전문가")
            badgeImages.append(BitnagilGraphic.noneBadgeGraphic)
        case 2:
            badgeTitleLabel.text = "하나만 더 모으면\n이번 달이 완성돼요!"
            badgeExpertView.configure(expertTitle: "능숙한 전문가")
            badgeImages = badges.map({ $0.multipleImage })
        case 3:
            badgeTitleLabel.text = "꾸준함이 이번 달을\n가득 채웠어요!"
            badgeExpertView.configure(expertTitle: "완벽한 전문가")
            badgeImages = badges.map({ $0.multipleImage })
        default:
            badgeTitleLabel.text = badges.first?.badgeTitle
            badgeExpertView.configure(expertTitle: badges.first?.expertTitle ?? "")
            badgeImages.append(badges.first?.singleImage)
        }

        badgeImageStackView.arrangedSubviews.forEach {
            badgeImageStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let badgeImageSize: CGFloat = badges.count > 1 ? Layout.badgeImagemultipleSize : Layout.badgeImageSingleSize
        badgeImages.forEach { badgeImage in
            let imageView = UIImageView()
            imageView.image = badgeImage
            imageView.contentMode = .scaleAspectFit
            imageView.snp.makeConstraints { make in
                make.size.equalTo(badgeImageSize)
            }
            badgeImageStackView.addArrangedSubview(imageView)
        }
    }
}
