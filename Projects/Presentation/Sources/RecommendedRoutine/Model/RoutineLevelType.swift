//
//  RoutineLevelType.swift
//  Presentation
//
//  Created by 최정인 on 7/17/25.
//

enum RoutineLevelType: CaseIterable {
    case easy
    case normal
    case hard

    var id: Int {
        switch self {
        case .easy: 1
        case .normal: 2
        case .hard: 3
        }
    }

    var levelTitle: String {
        switch self {
        case .easy: "가볍게 할 수 있어요"
        case .normal: "조금 신경써서 할 수 있어요"
        case .hard: "의지를 다 잡고 할 수 있어요"
        }
    }
}
