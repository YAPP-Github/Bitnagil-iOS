//
//  RoutineLevelType.swift
//  Presentation
//
//  Created by 최정인 on 7/17/25.
//

import Domain

extension RoutineLevelType: SelectableItem {
    var id: Int {
        switch self {
        case .easy: 1
        case .normal: 2
        case .hard: 3
        }
    }

    var displayName: String? {
        switch self {
        case .easy: "난이도 하"
        case .normal: "난이도 중"
        case .hard: "난이도 상"
        }
    }

    var description: String {
        switch self {
        case .easy: "\(self.displayName ?? "")  |  가볍게 할 수 있어요"
        case .normal: "\(self.displayName ?? "")  |  조금 신경써서 할 수 있어요"
        case .hard: "\(self.displayName ?? "")  |  의지를 다 잡고 할 수 있어요"
        }
    }
}
