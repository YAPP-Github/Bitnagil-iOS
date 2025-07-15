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
        case .morningTime: "MORNING"
        case .eveningTime: "EVENING"
        case .allTime: "NOTHING"

        case .never: "ZERO_PER_WEEK"
        case .rarely: "ONE_TO_TWO_PER_WEEK"
        case .sometimes: "THREE_TO_FOUR_PER_WEEK"
        case .often: "MORE_THAN_FIVE_PER_WEEK"

        case .stability: "STABILITY"
        case .connection: "CONNECTEDNESS"
        case .growth: "GROWTH"
        case .vitality: "VITALITY"

        case .once: "ONE_TO_TWO_PER_WEEK"
        case .twoToThree: "THREE_TO_FOUR_PER_WEEK"
        case .fourOrMore: "MORE_THAN_FIVE_PER_WEEK"
        case .notSure: "UNKNOWN"
        }
    }
}
