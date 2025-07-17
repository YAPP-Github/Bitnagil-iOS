//
//  RoutineCategoryType.swift
//  Presentation
//
//  Created by 최정인 on 7/12/25.
//

enum RoutineCategoryType: CaseIterable {
    case recommendation
    case outdoor
    case wakeup
    case connection
    case rest
    case growth

    var id: Int {
        switch self {
        case .recommendation: 1
        case .outdoor: 2
        case .wakeup: 3
        case .connection: 4
        case .rest: 5
        case .growth: 6
        }
    }

    var title: String {
        switch self {
        case .recommendation: "맞춤 추천"
        case .outdoor: "나가봐요"
        case .wakeup: "일어나요"
        case .connection: "연결해요"
        case .rest: "쉬어가요"
        case .growth: "성장해요"
        }
    }
}
