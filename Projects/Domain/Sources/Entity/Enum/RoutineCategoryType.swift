//
//  RoutineCategoryType.swift
//  Domain
//
//  Created by 최정인 on 7/27/25.
//

public enum RoutineCategoryType: String, CaseIterable {
    case recommendation = "PERSONALIZED"
    case outdoor = "OUTING"
    case outdoorReport = "OUTING_REPORT"
    case wakeup = "WAKE_UP"
    case connection = "CONNECT"
    case rest = "REST"
    case growth = "GROW"
}
