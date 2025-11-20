//
//  ReportEndpoint.swift
//  DataSource
//
//  Created by 최정인 on 11/20/25.
//

enum ReportEndpoint {
    case fetchReportDetail(reportId: Int)
}

extension ReportEndpoint: Endpoint {
    var baseURL: String {
        switch self {
        case .fetchReportDetail:
            return AppProperties.baseURL + "/api/v2/reports"
        }
    }

    var path: String {
        switch self {
        case .fetchReportDetail(let reportId):
            "\(baseURL)/\(reportId)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchReportDetail:
                .get
        }
    }

    var headers: [String : String] {
        let headers: [String: String] = [
            "Content-Type": "application/json",
            "accept": "*/*"
        ]
        return headers
    }

    var queryParameters: [String : String] {
        return [:]
    }

    var bodyParameters: [String : Any] {
        return [:]
    }

    var isAuthorized: Bool {
        return true
    }
}
