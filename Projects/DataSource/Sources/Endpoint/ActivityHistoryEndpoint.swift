//
//  ActivityHistoryEndpoint.swift
//  DataSource
//
//  Created by 최정인 on 7/15/26.
//

import Domain

enum ActivityHistoryEndpoint {
    case fetchMonthlyBadges(year: String, month: String)
    case fetchEmotionHistory(startDate: String, endDate: String)
}

extension ActivityHistoryEndpoint: Endpoint {
    var baseURL: String {
        return AppProperties.baseURL + "/api/v1/activity-logs"
    }

    var path: String {
        switch self {
        case .fetchMonthlyBadges:
            return baseURL + "/badges"
        case .fetchEmotionHistory:
            return baseURL + "/emotion-marbles"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchMonthlyBadges: .get
        case .fetchEmotionHistory: .get
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
        switch self {
        case .fetchMonthlyBadges(let year, let month):
            return [
                "year": year,
                "month": month]
        case .fetchEmotionHistory(let startDate, let endDate):
            return [
                "startDate": startDate,
                "endDate": endDate]
        }
    }

    var bodyParameters: [String : Any] {
        return [:]
    }

    var isAuthorized: Bool {
        return true
    }
}
