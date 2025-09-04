//
//  OnboardingDTO.swift
//  DataSource
//
//  Created by 최정인 on 8/27/25.
//

import Domain

struct OnboardingDTO: Encodable {
    let timeSlot: String
    let emotionType: [String]
    let realOutingFrequency: String?
    let targetOutingFrequency: String

    func toOnboardingEntity() -> OnboardingEntity {
        return OnboardingEntity(
            time: timeSlot,
            feeling: emotionType,
            frequency: realOutingFrequency,
            outdoor: targetOutingFrequency)
    }
}
