//
//  RefreshTokenPlugin.swift
//  DataSource
//
//  Created by 이동현 on 7/29/25.
//

import Foundation
import Shared

struct RefreshTokenPlugin: NetworkPlugin {
    func willSend(request: URLRequest, endpoint: Endpoint) async throws -> URLRequest {
        return request
    }

    func didReceive(response: URLResponse, data: Data?, endpoint: Endpoint) async throws {
        guard
            let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 401
        else { return }


        try await refreshAccessToken()
    }

    private func refreshAccessToken() async throws {
        do {
            let tokenManager = TokenManager.shared

            let refreshToken = try tokenManager.loadToken(tokenType: .refreshToken)
            let endpoint = AuthEndpoint.reissue(refreshToken: refreshToken)

            guard let tokenResponse = try await NetworkService.shared.request(
                endpoint: endpoint,
                type: TokenResponseDTO.self,
                withPlugins: false)
            else { throw NetworkError.unknown(description: "토큰 갱신 실패") }

            try tokenManager.saveToken(token: tokenResponse.accessToken, tokenType: .accessToken)
            try tokenManager.saveToken(token: tokenResponse.refreshToken, tokenType: .refreshToken)

            BitnagilLogger.log(logType: .debug, message: "AccessToken Saved: \(tokenResponse.accessToken)")
            BitnagilLogger.log(logType: .debug, message: "RefreshToken Saved: \(tokenResponse.refreshToken)")
        } catch {
            BitnagilLogger.log(logType: .error, message: "\(error.localizedDescription)")
            throw error
        }
    }
}
