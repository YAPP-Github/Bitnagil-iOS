//
//  MonthlyBadgesDTO.swift
//  DataSource
//
//  Created by 최정인 on 7/21/26.
//

import Domain

struct MonthlyBadgesDTO: Decodable {
    let badgeTitle: String
    let badgeDescription: String
    let badges: [BadgeDTO]

    func toBadgeEntity() -> BadgeEntity {
        return BadgeEntity(
            title: badgeTitle,
            description: badgeDescription,
            imageUrls: badges.map({ $0.imageUrl }))
    }
}

struct BadgeDTO: Decodable {
    let badgeType: String
    let imageUrl: String
    let acquiredAt: String?
}
