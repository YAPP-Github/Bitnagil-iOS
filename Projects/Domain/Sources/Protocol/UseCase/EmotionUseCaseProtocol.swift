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
}
