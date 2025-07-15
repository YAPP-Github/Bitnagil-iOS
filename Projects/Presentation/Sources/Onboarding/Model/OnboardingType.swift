//
//  OnboardingType.swift
//  Presentation
//
//  Created by 최정인 on 7/11/25.
//

import Domain

extension OnboardingType {
    
    var step: Int {
        switch self {
        case .time: 1
        case .frequency: 2
        case .feeling: 3
        case .outdoor: 4
        }
    }

    var mainTitle: String {
        switch self {
        case .time: "어떤 시간대를\n더 잘 보내고 싶나요?"
        case .frequency: "최근 얼마나 자주\n바깥 바람을 쐬시나요?"
        case .feeling: "요즘 어떤 회복이\n필요하신가요?"
        case .outdoor: "작지만 의미 있는 변화를 위해,\n일주일에 몇 번 외출하고 싶으신가요?"
        }
    }

    var subTitle: String? {
        switch self {
        case .time: nil
        case .frequency: nil
        case .feeling: "여러 개 선택할 수 있어요!"
        case .outdoor: "무리하지 않는 선에서, 나만의 외출 목표를 정해보세요."
        }
    }

    var choices: [OnboardingChoiceType] {
        switch self {
        case .time:
            return [OnboardingChoiceType.morningTime,
                    OnboardingChoiceType.eveningTime,
                    OnboardingChoiceType.allTime]

        case .frequency:
            return [OnboardingChoiceType.never,
                    OnboardingChoiceType.rarely,
                    OnboardingChoiceType.sometimes,
                    OnboardingChoiceType.often]

        case .feeling:
            return [OnboardingChoiceType.stability,
                    OnboardingChoiceType.connection,
                    OnboardingChoiceType.growth,
                    OnboardingChoiceType.vitality]

        case .outdoor:
            return [OnboardingChoiceType.once,
                    OnboardingChoiceType.twoToThree,
                    OnboardingChoiceType.fourOrMore,
                    OnboardingChoiceType.notSure]
        }
    }
}
