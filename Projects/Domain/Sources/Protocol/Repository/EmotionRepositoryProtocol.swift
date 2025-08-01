//
//  EmotionRepositoryProtocol.swift
//  Domain
//
//  Created by 최정인 on 7/28/25.
//

/// 감정 구슬에 대한 로직을 처리하는 Repository
public protocol EmotionRepositoryProtocol {
    /// 감정 구슬 목록을 불러옵니다.
    /// - Returns: 조회된 감정 구슬 목록
    func fetchEmotions() async throws -> [EmotionEntity]
    
    /// 해당하는 날짜에 등록한 감정 구슬을 조회합니다.
    /// - Parameter date: 조회하고 싶은 날짜 (yyyy-MM-dd)
    /// - Returns: 등록한 감정 구슬
    func fetchEmotion(date: String) async throws -> EmotionEntity?

    /// 감정 구슬을 등록합니다.
    /// - Parameter emotion: 감정 구슬 String 값
    /// - Returns: 등록한 감정 구슬에 따른 추천 루틴 리스트
    func registerEmotion(emotion: String) async throws -> [RecommendedRoutineEntity]
}
