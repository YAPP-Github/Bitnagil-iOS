//
//  RoutineRepositoryProtocol.swift
//  Domain
//
//  Created by 최정인 on 7/30/25.
//

// 루틴 관련 로직(조회, 완료, 등록, 삭제 등)을 수행하는 Repository
public protocol RoutineRepositoryProtocol {
    /// 루틴을 생성합니다.
    /// - Parameters:
    ///   - routineSummary: 루틴 요약 정보
    ///   - subRoutineSummaries: 서브 루틴 요약 정보 배열
    func createRoutine(routineSummary: RoutineSummaryEntity, subRoutineSummaries: [SubRoutineSummaryEntity]) async throws

    /// 루틴을 조회합니다.
    /// - Parameter routineId: 조회할 루틴 id
    /// - Returns: 조회된 루틴
    func fetchRoutine(routineId: String) async throws -> RoutineEntity?

    /// 루틴 목록을 조회합니다. (기간)
    /// - Parameters:
    ///   - startDate: 조회 시작 날짜
    ///   - endDate: 조회 종료 날짜
    func fetchRoutines(from startDate: String, to endDate: String) async throws -> [String: [RoutineEntity]]

    /// 루틴을 수정합니다.
    /// - Parameters:
    ///   - routineSummary: 루틴 요약 정보
    ///   - subRoutineSummaries: 서브 루틴 요약 정보 배열
    func updateRoutine(routineSummary: RoutineSummaryEntity, subRoutineSummaries: [SubRoutineSummaryEntity]) async throws

    /// 반복되는 루틴을 모두 제거합니다.
    /// - Parameter routineId: 삭제할 루틴 id
    func deleteAllRoutine(routineId: String) async throws

    /// 당일 루틴을 삭제합니다.
    /// - Parameter routine: 삭제할 루틴 정보
    func deleteDailyRoutine(routine: DeleteRoutineEntity) async throws
}
