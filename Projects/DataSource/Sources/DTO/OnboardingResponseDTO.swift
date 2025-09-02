//
//  OnboardingResponseDTO.swift
//  DataSource
//
//  Created by 최정인 on 9/1/25.
//

import Domain

struct OnboardingResponseDTO: Decodable {
    let timeSlot: String
    let emotionTypes: [String]
    let targetOutingFrequency: String

    func toOnboardingEntity() -> OnboardingEntity {
        return OnboardingEntity(
            time: timeSlot,
            feeling: emotionTypes,
            outdoor: targetOutingFrequency)
    }
}
