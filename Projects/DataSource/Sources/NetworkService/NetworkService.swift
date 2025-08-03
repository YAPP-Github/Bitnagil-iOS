//
//  NetworkService.swift
//  NetworkService
//
//  Created by 최정인 on 6/19/25.
//

import Foundation
import Shared

final class NetworkService {
    static let shared = NetworkService()
    private let decoder = JSONDecoder()
    private let plugins: [NetworkPlugin]
    private let maxRetryCount = 1

    private init() {
        plugins = [
            TokenInjectionPlugin(),
            RefreshTokenPlugin(),
            RetryPlugin(),
            BitnagilLoggingPlugin()]
    }

    func request<T: Decodable>(
        endpoint: Endpoint,
        type: T.Type,
        withPlugins: Bool = true
    ) async throws -> T? {
        var retryCount = 0

        while true {
            do {
                return try await performRequest(
                    endpoint: endpoint,
                    type: type,
                    withPlugins: withPlugins)
            } catch let error as NetworkError {
                guard
                    error == .needRetry,
                    retryCount < maxRetryCount
                else { throw error }

                retryCount += 1
                continue
            }
        }
    }

    private func performRequest<T: Decodable>(
        endpoint: Endpoint,
        type: T.Type,
        withPlugins: Bool = true
    ) async throws -> T? {
        var request = try endpoint.makeURLRequest()

        if withPlugins {
            for plugin in plugins {
                request = try await plugin.willSend(request: request, endpoint: endpoint)
            }
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        if withPlugins {
            for plugin in plugins {
                try await plugin.didReceive(
                    response: response,
                    data: data,
                    endpoint: endpoint)
            }
        }

        guard let httpResponse = response as? HTTPURLResponse
        else { throw NetworkError.invalidResponse }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.invalidStatusCode(statusCode: httpResponse.statusCode)
        }

        guard !data.isEmpty else { throw NetworkError.emptyData }

        do {
            let baseResponse = try decoder.decode(BaseResponse<T>.self, from: data)

            guard let responseDTO = baseResponse.data else { return nil }

            return responseDTO
        } catch {
            throw NetworkError.decodingError
        }
    }
}
