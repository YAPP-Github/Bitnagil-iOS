//
//  ReportType+.swift
//  Presentation
//
//  Created by 이동현 on 11/9/25.
//

import Domain

extension ReportType {
    var id: Int {
        switch self {
        case .transportation:
            return 0
        case .lamp:
            return 1
        case .water:
            return 2
        case .convenience:
            return 3
        }
    }

    var name: String {
        switch self {
        case .transportation:
            "교통 시설"
        case .lamp:
            "조명 시설"
        case .water:
            "상하수도 시설"
        case .convenience:
            "편의 시설"
        }
    }

    var description: String {
        switch self {
        case .transportation:
            "신호등 고장, 표지판 파손, 횡단보도 등"
        case .lamp:
            "가로등, 보안등 파손 등"
        case .water:
            "맨홀 뚜껑 손상 등"
        case .convenience:
            "벤치 파손, 휴지통 넘침 등"
        }
    }
}
