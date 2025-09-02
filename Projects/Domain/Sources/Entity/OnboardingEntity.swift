//
//  OnboardingEntity.swift
//  Domain
//
//  Created by 최정인 on 8/27/25.
//

public struct OnboardingEntity {
    public let time: String
    public let feeling: [String]
    public let frequency: String?
    public let outdoor: String

    public init(
        time: String,
        feeling: [String],
        frequency: String? = nil,
        outdoor: String
    ) {
        self.time = time
        self.feeling = feeling
        self.frequency = frequency
        self.outdoor = outdoor
    }
}
