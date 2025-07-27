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

    private init() { }

    func request<T: Decodable>(endpoint: Endpoint, type: T.Type) async throws -> T? {
        var request = try endpoint.makeURLRequest()
        if endpoint.isAuthorized {
            let accessToken = try TokenManager.shared.loadToken(tokenType: .accessToken)
            request.headers["Authorization"] = "Bearer \(accessToken)"
        }
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse
        else { throw NetworkError.invalidResponse }

        guard 200..<300 ~= httpResponse.statusCode else {
            BitnagilLogger.log(logType: .error, message: "응답 코드: \(httpResponse.statusCode)")
            throw NetworkError.invalidStatusCode(statusCode: httpResponse.statusCode)
        }

        guard !data.isEmpty
        else { throw NetworkError.emptyData }

        do {
            let baseResponse = try decoder.decode(BaseResponse<T>.self, from: data)
            BitnagilLogger.log(logType: .info, message: "Server Message: \(baseResponse.message)")

            guard let responseDTO = baseResponse.data
            else { return nil }
            
            return responseDTO
        } catch {
            throw NetworkError.decodingError
        }
    }
}
