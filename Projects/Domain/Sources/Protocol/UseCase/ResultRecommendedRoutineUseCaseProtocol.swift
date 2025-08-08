//
//  ResultRecommendedRoutineUseCaseProtocol.swift
//  Domain
//
//  Created by 최정인 on 7/29/25.
//

import Foundation

public protocol ResultRecommendedRoutineUseCaseProtocol {
    /// 선택한 온보딩 결과를 저장하고, 추천 루틴을 받습니다.
    /// - Parameter onboardingChoices: 선택한 온보딩 항목 list
    /// - Returns: 온보딩 결과를 바탕으로 받은 추천루틴 목록
    func fetchResultRecommendedRoutines(onboardingChoices: [OnboardingChoiceType]) async throws -> [RecommendedRoutineEntity]

    /// 감정 구슬을 등록하고 그에 따른 추천 루틴 리스트를 받습니다.
    /// - Parameter emotion: 감정 구슬 타입 String
    /// - Returns: 등록한 감정 구슬에 따른 추천 루틴 리스트
    func fetchResultRecommendedRoutines(emotion: String) async throws -> [RecommendedRoutineEntity]

    /// 선택한 추천 루틴을 등록합니다.
    /// - Parameter selectedRoutines: 선택한 추천 루틴 ID 목록
    func registerRecommendedRoutines(selectedRoutines: [Int]) async throws
}
