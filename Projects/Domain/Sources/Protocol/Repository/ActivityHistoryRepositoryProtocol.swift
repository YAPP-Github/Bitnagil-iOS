//
//  ActivityHistoryRepositoryProtocol.swift
//  Domain
//
//  Created by 최정인 on 7/21/26.
//

/// 활동 기록 관련 로직(월 별 뱃지 조회, 감정 구슬 기록 조회 등)을 수행하는 Repository
public protocol ActivityHistoryRepositoryProtocol {
    /// 월 별 뱃지를 조회합니다.
    /// - Parameters:
    ///   - year: 조회하려고 하는 연도
    ///   - month: 조회하려고 하는 월
    func fetchMonthlyBadges(year: Int, month: Int) async throws -> BadgeEntity

    /// 기간 내 감정 구슬 기록을 조회합니다.
    /// - Parameters:
    ///   - startDate: 조회 시작 날짜 (yyyy-MM-dd)
    ///   - endDate: 조회 종료 날짜 (yyyy-MM-dd)
    func fetchEmotionMarbles(startDate: String, endDate: String) async throws -> [EmotionHistoryEntity]
}
