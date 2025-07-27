//
//  Date+.swift
//  Presentation
//
//  Created by 최정인 on 7/18/25.
//

import Foundation

extension Date {
    func convertToString(dateType: DateType) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = dateType.formatString

        return formatter.string(from: self)
    }

    enum DateType {
        case yearMonthDate
        case yearMonth
        case dayOfWeek
        case date
        case amPmTime
        case amPmTimeShort

        var formatString: String {
            switch self {
            case .yearMonthDate: "yyyy-MM-dd"
            case .yearMonth: "yyyy년 M월"
            case .dayOfWeek: "E"
            case .date: "d"
            case .amPmTime: "a HH:mm"
            case .amPmTimeShort: "a h:mm"
            }
        }
    }
}
