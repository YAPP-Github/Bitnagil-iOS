//
//  YouthPolicyDTO.swift
//  DataSource
//

import Domain
import Foundation

struct YouthPolicyDTO: Decodable {
    let plcyNo: String
    let title: String
    let category: String?
    let thumbnailUrl: String?
    let status: String
    let startDate: String?
    let endDate: String?
    let dday: Int?
    let applyUrl: String?
    let bookmarked: Bool
}

extension YouthPolicyDTO {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter
    }()

    func toYouthPolicyEntity() -> YouthPolicyEntity? {
        guard let status = YouthPolicyStatus(rawValue: status) else { return nil }

        return YouthPolicyEntity(
            policyNumber: plcyNo,
            title: title,
            category: category,
            thumbnailURL: thumbnailUrl,
            status: status,
            startDate: startDate.flatMap { Self.dateFormatter.date(from: $0) },
            endDate: endDate.flatMap { Self.dateFormatter.date(from: $0) },
            dday: dday,
            applyURL: applyUrl,
            isBookmarked: bookmarked)
    }
}

struct YouthPolicyPageDTO: Decodable {
    let totalCount: Int
    let hasNext: Bool
    let nextCursor: String?
    let items: [YouthPolicyDTO]

    func toYouthPolicyPageEntity() -> YouthPolicyPageEntity {
        return YouthPolicyPageEntity(
            policies: items.compactMap { $0.toYouthPolicyEntity() },
            totalCount: totalCount,
            hasNext: hasNext,
            nextCursor: nextCursor)
    }
}
