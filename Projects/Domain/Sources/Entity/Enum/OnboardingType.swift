//
//  OnboardingType.swift
//  Domain
//
//  Created by 최정인 on 7/15/25.
//

public enum OnboardingType: CaseIterable {
    case time
    case frequency
    case feeling
    case outdoor

    var key: String {
        switch self {
        case .time: "timeSlot"
        case .frequency: "realOutingFrequency"
        case .feeling: "emotionType"
        case .outdoor: "targetOutingFrequency"
        }
    }
}
