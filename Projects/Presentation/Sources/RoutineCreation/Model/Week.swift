//
//  Week.swift
//  Presentation
//
//  Created by 이동현 on 7/21/25.
//

enum Week: Int, CaseIterable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday

    var koreanValue: String {
        switch self {
        case .monday:
            "월"
        case .tuesday:
            "화"
        case .wednesday:
            "수"
        case .thursday:
            "목"
        case .friday:
            "금"
        case .saturday:
            "토"
        case .sunday:
            "일"
        }
    }
}
