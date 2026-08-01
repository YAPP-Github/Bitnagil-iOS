//
//  YouthPolicyBadge.swift
//  Presentation
//

import Domain
import UIKit

enum YouthPolicyBadge: Hashable {
    /// 신청 기간 내. 마감까지 남은 일수를 함께 가집니다.
    case dday(Int)
    /// 상시 모집
    case always
    /// 마감됨
    case closed

    /// 마감 임박으로 강조할 기준 일수입니다. 이 값 이하로 남으면 빨간 뱃지를 사용합니다.
    private static let deadlineThreshold: Int = 7

    init?(status: YouthPolicyStatus, dday: Int?) {
        switch status {
        case .open:
            // 서버 명세상 status가 open이면 dday는 항상 내려옵니다.
            guard let dday else { return nil }
            self = .dday(dday)
        case .always:
            self = .always
        case .closed:
            self = .closed
        }
    }

    var description: String {
        switch self {
        case .dday(let dday):
            dday == 0 ? "D-DAY" : "D-\(dday)"
        case .always:
            "상시"
        case .closed:
            "마감"
        }
    }

    var backgroundColor: UIColor? {
        switch self {
        case .dday(let dday):
            dday <= Self.deadlineThreshold ? BitnagilColor.pink10 : BitnagilColor.green10
        case .always:
            // TODO: - 상시/마감 뱃지 색상 디자이너 확인 필요
            BitnagilColor.green10
        case .closed:
            BitnagilColor.gray95
        }
    }

    var titleColor: UIColor? {
        switch self {
        case .dday(let dday):
            dday <= Self.deadlineThreshold ? BitnagilColor.red500 : BitnagilColor.green300
        case .always:
            // TODO: - 상시/마감 뱃지 색상 디자이너 확인 필요
            BitnagilColor.green300
        case .closed:
            BitnagilColor.gray40
        }
    }
}
