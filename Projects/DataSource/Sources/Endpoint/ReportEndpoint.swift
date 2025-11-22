//
//  ReportEndpoint.swift
//  DataSource
//
//  Created by 최정인 on 11/20/25.
//

enum ReportEndpoint {
    case register(report: ReportDTO)
    case fetchReports
    case fetchReportDetail(reportId: Int)
}

extension ReportEndpoint: Endpoint {
    var baseURL: String {
        return AppProperties.baseURL + "/api/v2/reports"
    }

    var path: String {
        switch self {
        case .register, .fetchReports:
            return baseURL
        case .fetchReportDetail(let reportId):
            return "\(baseURL)/\(reportId)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case.register:
            return .post
        case .fetchReports, .fetchReportDetail:
            return .get
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
        switch self {
        case .register(let report):
            return report.dictionary
        case .fetchReports, .fetchReportDetail:
            return [:]
        }
    }

    var isAuthorized: Bool {
        return true
    }
}
