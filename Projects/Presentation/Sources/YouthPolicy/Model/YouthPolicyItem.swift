//
//  YouthPolicyItem.swift
//  Presentation
//

import Domain
import Foundation
import Shared

struct YouthPolicyItem: Hashable {
    let policyNumber: String
    let title: String
    let badge: YouthPolicyBadge
    /// "YY.MM.DD ~ YY.MM.DD" 형태의 신청 기간. 날짜가 없으면 빈 문자열입니다.
    let periodText: String
    let applyURL: URL?
    var isBookmarked: Bool
}

extension YouthPolicyItem {
    init?(entity: YouthPolicyEntity) {
        guard let badge = YouthPolicyBadge(status: entity.status, dday: entity.dday)
        else { return nil }

        self.policyNumber = entity.policyNumber
        self.title = entity.title
        self.badge = badge
        self.periodText = Self.makePeriodText(startDate: entity.startDate, endDate: entity.endDate)
        self.applyURL = entity.applyURL.flatMap { URL(string: $0) }
        self.isBookmarked = entity.isBookmarked
    }

    private static func makePeriodText(startDate: Date?, endDate: Date?) -> String {
        let startText = startDate?.convertToString(dateType: .yearMonthDateShort)
        let endText = endDate?.convertToString(dateType: .yearMonthDateShort)

        switch (startText, endText) {
        case (let start?, let end?):
            return "\(start) ~ \(end)"
        case (let start?, nil):
            return "\(start) ~"
        case (nil, let end?):
            return "~ \(end)"
        case (nil, nil):
            return ""
        }
    }
}
