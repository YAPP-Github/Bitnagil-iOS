//
//  TokenInjectionPlugin.swift
//  DataSource
//
//  Created by 이동현 on 7/29/25.
//

import Foundation

struct TokenInjectionPlugin: NetworkPlugin {
    func willSend(request: URLRequest, endpoint: any Endpoint) async throws -> URLRequest {
        guard endpoint.isAuthorized else { return request }

        var newRequest = request
        let accessToken = try TokenManager.shared.loadToken(tokenType: .accessToken)
        newRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        return newRequest
    }
    
    func didReceive(response: URLResponse, data: Data?, endpoint: any Endpoint) async throws {}
}
