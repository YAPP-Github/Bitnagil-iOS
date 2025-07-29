//
//  EmotionUseCaseProtocol.swift
//  Domain
//
//  Created by 최정인 on 7/28/25.
//

public protocol EmotionUseCaseProtocol {
    /// 감정 구슬 목록을 불러옵니다.
    /// - Returns: 조회된 감정 구슬 목록
    func fetchEmotions() async throws -> [EmotionEntity]

    /// 감정 구슬을 등록하고 그에 따른 추천 루틴 리스트를 받습니다.
    /// - Parameter emotion: 감정 구슬 타입 String
    /// - Returns: 등록한 감정 구슬에 따른 추천 루틴 리스트
    func registerEmotion(emotion: String) async throws -> [RecommendedRoutineEntity]
}
