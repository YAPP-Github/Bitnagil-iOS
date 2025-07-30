//
//  RoutineUseCaseProtocol.swift
//  Domain
//
//  Created by 최정인 on 7/30/25.
//

import Foundation

public protocol RoutineUseCaseProtocol {
    func fetchRoutines(startDate: Date, endDate: Date) async throws -> [String: [RoutineEntity]]
}
