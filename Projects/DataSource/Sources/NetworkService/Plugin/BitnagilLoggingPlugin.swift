//
//  BitnagilLoggingPlugin.swift
//  DataSource
//
//  Created by 이동현 on 8/3/25.
//

import Foundation
import Shared

struct BitnagilLoggingPlugin: NetworkPlugin {
    func willSend(request: URLRequest, endpoint: Endpoint) async throws -> URLRequest {
        let urlString = request.url?.absoluteString ?? ""
        let method = request.httpMethod ?? ""
        let headers = request.allHTTPHeaderFields ?? [:]
        let body: String
        if let bodyData = request.httpBody {
            body = String(data: bodyData, encoding: .utf8) ?? "디코딩 실패"
        } else {
            body = "내용 없음"
        }

        BitnagilLogger.log(
            logType: .debug,
            message: """
                    REQUEST➡️
                    - URL: \(urlString)
                    - Method: \(method)
                    - Headers: \(headers)
                    - Body: \(body)
                    """
        )
        return request
    }

    func didReceive(response: URLResponse, data: Data?, endpoint: Endpoint) async throws {
        let urlString = response.url?.absoluteString ?? ""

        guard let httpResponse = response as? HTTPURLResponse else {
            BitnagilLogger.log(logType: .error, message: "🚨\(urlString)에 대한 response는 HTTPResponse가 아닙니다.🚨")
            return
        }

        let statusCode = httpResponse.statusCode

        // code/message 추출
        var code: String = ""
        var message: String = ""
        if
            let data = data,
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        {
            code = json["code"] as? String ?? ""
            message = json["message"] as? String ?? ""
        }

        BitnagilLogger.log(
            logType: .debug,
            message: """
                RESPONSE⬅️
                - 요청URL: \(urlString)
                - Status: \(statusCode)
                - Code: \(code)
                - Message: \(message)
                """
        )
    }
}
