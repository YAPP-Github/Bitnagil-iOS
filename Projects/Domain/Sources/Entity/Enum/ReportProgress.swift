//
//  ReportProgress.swift
//  Domain
//
//  Created by 이동현 on 11/15/25.
//

public enum ReportProgress: CaseIterable {
    case entire
    case received
    case inProgress
    case completed

    public var description: String {
        switch self {
        case .entire:
            "전체"
        case .received:
            "제보 완료"
        case .inProgress:
            "처리 중"
        case .completed:
            "처리 완료"
        }
    }
}
