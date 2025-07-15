//
//  OnboardingUseCaseProtocol.swift
//  Domain
//
//  Created by 최정인 on 7/15/25.
//

public protocol OnboardingUseCaseProtocol {
    /// 선택한 온보딩 결과를 저장하고, 추천 루틴을 받습니다.
    /// - Parameter onboardingChoices: 선택한 온보딩 항목
    /// - Returns: 온보딩 결과를 바탕으로 받은 추천루틴 목록
    func registerOnboarding(onboardingChoices: [OnboardingChoiceType]) async throws -> [RecommendedRoutineEntity]

    /// 선택한 추천 루틴을 등록합니다.
    /// - Parameter selectedRoutines: 선택한 추천 루틴 ID 목록
    func registerRecommendedRoutines(selectedRoutines: [Int]) async throws
}
