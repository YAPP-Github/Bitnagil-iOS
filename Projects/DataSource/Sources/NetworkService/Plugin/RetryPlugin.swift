//
//  RetryPlugin.swift
//  DataSource
//
//  Created by 이동현 on 7/29/25.
//

import Foundation

struct RetryPlugin: NetworkPlugin {
    func willSend(request: URLRequest, endpoint: Endpoint) async throws -> URLRequest {
        return request
    }

    func didReceive(
        response: URLResponse,
        data: Data?,
        endpoint: Endpoint
    ) async throws {
        guard let httpResponse = response as? HTTPURLResponse else { return }

        switch httpResponse.statusCode {
        case 200..<300:
            return
        case 401: // TODO: - 재전송 정책 필요시 조정하기!!
            throw NetworkError.needRetry
        default:
            throw NetworkError.noRetry
        }
    }
}
