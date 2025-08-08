//
//  RoutienCreationDTO.swift
//  DataSource
//
//  Created by 이동현 on 8/3/25.
//

struct RoutineCreationDTO: Codable {
    let routineName: String
    let repeatDay: [String]
    let executionTime: String
    let subRoutineName: [String]
}
