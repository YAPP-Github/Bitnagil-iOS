//
//  EmotionCollectionViewLayout.swift
//  Presentation
//
//  Created by 이동현 on 8/19/25.
//

import UIKit

final class EmotionCollectionViewLayout: UICollectionViewFlowLayout {
    private let itemWidthRatio: CGFloat = 0.5
    private let lineSpacing: CGFloat = 16
    private var baseDistance: CGFloat { itemSize.width + minimumLineSpacing }

    override class var layoutAttributesClass: AnyClass { EmotionCollectionViewLayoutAttributes.self }

    override func prepare() {
        super.prepare()
        guard let collectionView else { return }

        scrollDirection = .horizontal
        minimumLineSpacing = lineSpacing

        let itemWidth = floor(collectionView.bounds.width * itemWidthRatio)
        let itemHeight = collectionView.bounds.height
        itemSize = CGSize(width: itemWidth, height: itemHeight)

        let insetX = (collectionView.bounds.width - itemWidth) / 2
        sectionInset = UIEdgeInsets(top: 0, left: insetX, bottom: 0, right: insetX)

        collectionView.decelerationRate = .fast
    }

    override func targetContentOffset(forProposedContentOffset proposed: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView else { return proposed }

        let visibleRect = CGRect(
            origin: CGPoint(x: proposed.x, y: collectionView.contentOffset.y),
            size: collectionView.bounds.size)

        guard
            let layoutAttributesList = super.layoutAttributesForElements(in: visibleRect),
            !layoutAttributesList.isEmpty
        else { return proposed }

        // 화면 중앙에 가장 가까운 셀 찾기
        let centerX = proposed.x + collectionView.bounds.width / 2
        let closestTarget = layoutAttributesList.min { abs($0.center.x - centerX) < abs($1.center.x - centerX) }

        guard let closestTarget else { return proposed }

        let newX = closestTarget.center.x - collectionView.bounds.width / 2
        return CGPoint(x: newX, y: proposed.y)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard
            let collectionView,
            let baseAttributesList = super.layoutAttributesForElements(in: rect)
        else { return super.layoutAttributesForElements(in: rect) }

        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2

        return baseAttributesList.map { base in
            guard let copied = base.copy() as? EmotionCollectionViewLayoutAttributes else { return base }

            let distanceFromCenter = abs(copied.center.x - centerX)
            let t = min(distanceFromCenter / baseDistance, 1)

            copied.progress = 1 - t
            return copied
        }
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
