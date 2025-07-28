//
//  RecommendedRoutineUseCaseProtocol.swift
//  Domain
//
//  Created by 최정인 on 7/27/25.
//

public protocol RecommendedRoutineUseCaseProtocol {
    /// 추천 루틴 데이터를 가져옵니다.
    /// - Returns: 추천 루틴 목록
    func fetchRecommendedRoutines() async throws -> [RecommendedRoutineEntity]
}
