//
//  RecommendedRoutineEntity.swift
//  Domain
//
//  Created by 최정인 on 7/15/25.
//

public struct RecommendedRoutineEntity {
    public let id: Int
    public let title: String
    public let description: String

    public init(
        id: Int,
        title: String,
        description: String
    ) {
        self.id = id
        self.title = title
        self.description = description
    }
}
