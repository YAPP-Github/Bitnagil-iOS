//
//  EmotionUseCaseProtocol.swift
//  Domain
//
//  Created by 최정인 on 7/28/25.
//

import Foundation

public protocol EmotionUseCaseProtocol {
    /// 감정 구슬 목록을 불러옵니다.
    /// - Returns: 조회된 감정 구슬 목록
    func fetchEmotions() async throws -> [EmotionEntity]

    /// 해당하는 날짜에 등록된 감정 구슬을 조회합니다.
    /// - Parameter date: 조회하고 싶은 날짜
    /// - Returns: 감정 구슬
    func fetchEmotion(date: Date) async throws -> EmotionEntity?
}
