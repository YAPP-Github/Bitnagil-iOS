//
//  BadgeEntity.swift
//  Domain
//
//  Created by 최정인 on 7/21/26.
//

public struct BadgeEntity {
    public let title: String
    public let description: String
    public let imageUrls: [String]

    public init(
        title: String,
        description: String,
        imageUrls: [String]
    ) {
        self.title = title
        self.description = description
        self.imageUrls = imageUrls
    }
}
