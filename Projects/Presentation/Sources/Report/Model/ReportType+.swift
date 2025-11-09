//
//  ReportType+.swift
//  Presentation
//
//  Created by 이동현 on 11/9/25.
//

import Domain

extension ReportType: SelectableItem {
    var id: Int {
        switch self {
        case .lamp:
            return 0
        case .road:
            return 1
        case .etc:
            return 2
        }
    }

    var displayName: String? {
        return nil
    }

    var description: String {
        switch self {
        case .lamp:
            return "가로등"
        case .road:
            return "도로"
        case .etc:
            return "기타"
        }
    }
}
