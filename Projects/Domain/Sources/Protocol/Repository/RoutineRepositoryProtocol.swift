//
//  RoutineRepositoryProtocol.swift
//  Domain
//
//  Created by 최정인 on 7/30/25.
//

// 루틴 관련 로직(조회, 완료, 등록, 삭제 등)을 수행하는 Repository
public protocol RoutineRepositoryProtocol {
    /// 루틴을 조회합니다. (기간)
    /// - Parameters:
    ///   - startDate: 조회 시작 날짜
    ///   - endDate: 조회 종료 날짜
    func fetchRoutines(from startDate: String, to endDate: String) async throws -> [String: [RoutineEntity]]
}
