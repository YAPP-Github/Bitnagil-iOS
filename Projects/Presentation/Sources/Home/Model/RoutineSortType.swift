//
//  RoutineSortType.swift
//  Presentation
//
//  Created by 최정인 on 7/24/25.
//

enum RoutineSortType: SelectableItem, CaseIterable {
    case complete
    case incomplete

    var id: Int {
        switch self {
        case .complete: 1
        case .incomplete: 2
        }
    }

    var title: String {
        switch self {
        case .complete: "완료한 루틴 순"
        case .incomplete: "미완료한 루틴 순"
        }
    }
}
