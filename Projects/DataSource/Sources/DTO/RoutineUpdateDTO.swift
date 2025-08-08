//
//  RoutineUpdateDTO.swift
//  DataSource
//
//  Created by 이동현 on 8/3/25.
//

struct RoutineUpdateDTO: Codable {
    let routineId: String
    let routineName: String
    let repeatDay: [String]
    let executionTime: String
    let subRoutineInfos: [SubRoutineUpdateDTO]
}
