//
//  BitnagilGraphic.swift
//  Presentation
//
//  Created by 최정인 on 7/27/25.
//

import UIKit

enum BitnagilGraphic {
    private static var bundle: Bundle {
        return Bundle(for: IntroView.self)
    }
    
    static let introGraphic = UIImage(named: "intro_graphic", in: bundle, with: nil)
    static let onboardingGraphic = UIImage(named: "onboarding_graphic", in: bundle, with: nil)
    static let defaultEmotionGraphic = UIImage(named: "default_emotion_graphic", in: bundle, with: nil)
    static let logoGraphic = UIImage(named: "bitnagil_logo", in: bundle, with: nil)
}
