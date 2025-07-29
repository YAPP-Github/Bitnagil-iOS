//
//  NetworkPlugin.swift
//  DataSource
//
//  Created by 이동현 on 7/29/25.
//

import Foundation

protocol NetworkPlugin {
    /// 네트워크 요청 전처리를 진행합니다.
    /// - Parameters:
    ///   - request: 요청할 request 객체
    ///   - endpoint: 요청할 엔드포인트
    /// - Returns: URLRequest 객체
    func willSend(request: URLRequest, endpoint: Endpoint) async throws -> URLRequest

    /// 네트워크 응답 후처리를 진행합니다.
    /// - Parameters:
    ///   - response: URLResponse 객체
    ///   - data: 통신 후 받은 데이터
    ///   - endpoint: 요청한 endpoint
    func didReceive(
        response: URLResponse,
        data: Data?,
        endpoint: Endpoint) async throws
}
