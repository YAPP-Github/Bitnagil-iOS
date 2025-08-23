//
//  EmotionCollectionViewLayoutAttributes.swift
//  Presentation
//
//  Created by 이동현 on 8/19/25.
//

import UIKit

final class EmotionCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    var progress: CGFloat = 0

    override func copy(with zone: NSZone? = nil) -> Any {
        let superCopy = super.copy(with: zone)

        guard let copied = superCopy as? EmotionCollectionViewLayoutAttributes else { return superCopy }

        copied.progress = progress
        return copied
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? EmotionCollectionViewLayoutAttributes else { return false }

        return super.isEqual(object) && object.progress == progress
    }
}
