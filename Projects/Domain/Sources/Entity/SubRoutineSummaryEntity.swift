//
//  SubRoutineSummaryEntity.swift
//  Domain
//
//  Created by 이동현 on 8/3/25.
//

public struct SubRoutineSummaryEntity: Decodable, Hashable {
    public let subRoutineId: String?
    public let subRoutineName: String?
    public let sortOrder: Int?

    public init(
        subRoutineId: String?,
        subRoutineName: String?,
        sortOrder: Int?
    ) {
        self.subRoutineId = subRoutineId
        self.subRoutineName = subRoutineName
        self.sortOrder = sortOrder
    }
}
