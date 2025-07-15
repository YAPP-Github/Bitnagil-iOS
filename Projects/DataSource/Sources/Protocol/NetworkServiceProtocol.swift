//
//  NetworkServiceProtocol.swift
//  DataSource
//
//  Created by 최정인 on 6/20/25.
//

import Foundation

public protocol NetworkServiceProtocol {
    /// Endpoint로 비동기 네트워크 요청을 수행하고, 응답 데이터를 디코딩하여 반환합니다.
    /// 네트워크 오류 또는 디코딩 오류가 발생한 경우, NetworkError를 throw 합니다.
    ///
    /// - Parameters:
    ///   - endpoint: 요청을 보낼 API Endpoint 정보
    ///   - type: 디코딩할 Response DTO 타입
    /// - Returns: 응답 데이터를 디코딩한 객체
    func request<T: Decodable>(endpoint: Endpoint, type: T.Type) async throws -> T
}
