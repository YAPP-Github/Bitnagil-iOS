//
//  OnboardingChoiceType.swift
//  Domain
//
//  Created by 최정인 on 7/15/25.
//

public enum OnboardingChoiceType: CaseIterable {
    case morningTime
    case eveningTime
    case allTime

    case never
    case rarely
    case sometimes
    case often

    case stability
    case connection
    case growth
    case vitality

    case once
    case twoToThree
    case fourOrMore
    case notSure

    public var onboardingType: OnboardingType {
        switch self {
        case .morningTime: .time
        case .eveningTime: .time
        case .allTime: .time

        case .never: .frequency
        case .rarely: .frequency
        case .sometimes: .frequency
        case .often: .frequency

        case .stability: .feeling
        case .connection: .feeling
        case .growth: .feeling
        case .vitality: .feeling

        case .once: .outdoor
        case .twoToThree: .outdoor
        case .fourOrMore: .outdoor
        case .notSure: .outdoor
        }
    }

    var value: String {
        switch self {
        case .morningTime: "08:00:00"
        case .eveningTime: "20:00:00"
        case .allTime: "00:00:00"

        case .never: "NEVER"
        case .rarely: "SHORT"
        case .sometimes: "SOMETIMES"
        case .often: "OFTEN"

        case .stability: "STABILITY"
        case .connection: "CONNECTEDNESS"
        case .growth: "GROWTH"
        case .vitality: "VITALITY"

        case .once: "ONE_PER_WEEK"
        case .twoToThree: "TWO_TO_THREE_PER_WEEK"
        case .fourOrMore: "MORE_THAN_FOUR_PER_WEEK"
        case .notSure: "UNKNOWN"
        }
    }
}
