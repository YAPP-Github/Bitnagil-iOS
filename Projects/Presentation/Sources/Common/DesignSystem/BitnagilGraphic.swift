//
//  BitnagilGraphic.swift
//  Presentation
//
//  Created by 최정인 on 7/27/25.
//

import UIKit

enum BitnagilGraphic {
    private static var bundle: Bundle {
        return Bundle(for: IntroViewController.self)
    }

    // MARK: - Onboarding
    static let introLabelGraphic = UIImage(named: "intro_label_graphic", in: bundle, with: nil)
    static let introFomoGraphic = UIImage(named: "intro_fomo_graphic", in: bundle, with: nil)
    static let loginGraphic = UIImage(named: "login_graphic", in: bundle, with: nil)
    static let onboardingRectangle = UIImage(named: "rounded_rectangle", in: bundle, with: nil)
    static let onboardingBigRectangle = UIImage(named: "rounded_big_rectangle", in: bundle, with: nil)
    static let onboardingFomoGraphic = UIImage(named: "onboarding_fomo_graphic", in: bundle, with: nil)
    static let onboardingGrayLine = UIImage(named: "gray_line", in: bundle, with: nil)
    static let progressStep1 = UIImage(named: "progress_step1", in: bundle, with: nil)
    static let progressStep2 = UIImage(named: "progress_step2", in: bundle, with: nil)
    static let progressStep3 = UIImage(named: "progress_step3", in: bundle, with: nil)
    static let progressStep4 = UIImage(named: "progress_step4", in: bundle, with: nil)
    static let progressStep5 = UIImage(named: "progress_step5", in: bundle, with: nil)

    // MARK: - Home
    static let defaultEmotionHandGraphic = UIImage(named: "default_emotion_with_hand_graphic", in: bundle, with: nil)

    static let defaultEmotionGraphic = UIImage(named: "default_emotion_graphic", in: bundle, with: nil)
    static let logoGraphic = UIImage(named: "bitnagil_logo", in: bundle, with: nil)
    static let profileGraphic = UIImage(named: "profile_graphic", in: bundle, with: nil)
    static let grayLogoGraphic = UIImage(named: "bitnagil_logo_gray", in: bundle, with: nil)
}
