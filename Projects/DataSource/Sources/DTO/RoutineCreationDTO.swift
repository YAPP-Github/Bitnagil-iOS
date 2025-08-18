//
//  RoutienCreationDTO.swift
//  DataSource
//
//  Created by 이동현 on 8/3/25.
//

import Domain

struct RoutineCreationDTO: Codable {
    let routineId: String?
    let updateApplyDate: String?
    let routineName: String
    let repeatDay: [String]
    let routineStartDate: String
    let routineEndDate: String
    let executionTime: String
    let subRoutineName: [String]
    let recommendedRoutineType: String?
}

extension RoutineCreationDTO {
    func toRoutineCreationEntity() -> RoutineCreationEntity {
        let weeks = repeatDay.compactMap { Week(rawValue: $0) }
        let routineCategoryType = RoutineCategoryType(rawValue: recommendedRoutineType ?? "")

        return RoutineCreationEntity(
            id: routineId,
            name: routineName,
            repeatDay: weeks,
            startDate: routineStartDate,
            endDate: routineEndDate,
            executionTime: executionTime,
            subroutines: subRoutineName,
            recommendedRoutineType: routineCategoryType,
            applyDateType: nil)
    }
}
