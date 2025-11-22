//
//  Date+.swift
//  Presentation
//
//  Created by 최정인 on 7/18/25.
//

import Foundation

extension Date {
    public var isMidnight: Bool {
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: self)
        return components.hour == 0 && components.minute == 0
    }

    public func convertToString(dateType: DateType) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = dateType.formatString

        return formatter.string(from: self)
    }

    public static func convertToDate(from string: String, dateType: DateType) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = dateType.formatString

        return formatter.date(from: string)
    }

    public enum DateType {
        case yearMonthDate
        case yearMonthDateShort
        case yearMonthDateWeek
        case yearMonthDateWeek2
        case yearMonth
        case dayOfWeek
        case date
        case time
        case time24hour
        case amPmTime
        case amPmTimeShort

        var formatString: String {
            switch self {
            case .yearMonthDate: "yyyy-MM-dd"
            case .yearMonthDateShort: "yy.MM.dd"
            case .yearMonthDateWeek: "yyyy-MM-dd E"
            case .yearMonthDateWeek2: "yyyy-MM-dd (E)"
            case .yearMonth: "yyyy년 M월"
            case .dayOfWeek: "E"
            case .date: "d"
            case .time: "HH:mm:ss"
            case .time24hour: "HH:mm"
            case .amPmTime: "a HH:mm"
            case .amPmTimeShort: "a h:mm"
            }
        }
    }
}
