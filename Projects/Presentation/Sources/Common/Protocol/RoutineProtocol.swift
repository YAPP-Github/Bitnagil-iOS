//
//  RoutineProtocol.swift
//  Presentation
//
//  Created by 최정인 on 8/20/25.
//

import Domain

protocol RoutineProtocol {
    var title: String { get }
    var routineType: RoutineCategoryType? { get }
    var subRoutines: [String] { get }
}
