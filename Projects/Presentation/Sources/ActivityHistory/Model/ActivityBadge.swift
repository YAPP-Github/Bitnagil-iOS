//
//  ActivityBadge.swift
//  Presentation
//
//  Created by 최정인 on 7/7/26.
//

import Domain

struct ActivityBadge {
    let title: String
    let description: String
    let imageUrls: [String]
}

extension BadgeEntity {
    func toActivityBadge() -> ActivityBadge {
        return ActivityBadge(
            title: title,
            description: description,
            imageUrls: imageUrls)
    }
}
