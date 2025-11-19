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

    // MARK: - Tutorial
    static let tutorialEmotionGraphic = UIImage(named: "tutorial_emotion_graphic", in: bundle, with: nil)
    static let tutorialHomeMoreGraphic = UIImage(named: "tutorial_home_more_graphic", in: bundle, with: nil)
    static let tutorialRecommendationRoutineGraphic = UIImage(named: "tutorial_recommendation_routine_graphic", in: bundle, with: nil)
    static let tutorialEditRoutineGraphic = UIImage(named: "tutorial_edit_routine_graphic", in: bundle, with: nil)

    // MARK: - Emotion
    static let marbleSpeechGraphic = UIImage(named: "marble_speech_graphic", in: bundle, with: nil)
    static let fomoHandGraphic = UIImage(named: "fomo_hand_graphic", in: bundle, with: nil)
    static let fomoThumbGraphic = UIImage(named: "fomo_thumb_graphic", in: bundle, with: nil)
    static let marbleRedGraphic = UIImage(named: "marble_red_graphic", in: bundle, with: nil)
    static let marbleNoneGraphic = UIImage(named: "marble_none_graphic", in: bundle, with: nil)
    static let marbleOrangeGraphic = UIImage(named: "marble_orange_graphic", in: bundle, with: nil)
    static let marbleMintGraphic = UIImage(named: "marble_mint_graphic", in: bundle, with: nil)
    static let marbleGreenGraphic = UIImage(named: "marble_green_graphic", in: bundle, with: nil)
    static let marbleGrayGraphic = UIImage(named: "marble_gray_graphic", in: bundle, with: nil)
    static let marblePurpleGraphic = UIImage(named: "marble_purple_graphic", in: bundle, with: nil)

    // MARK: - Emotion Register Completion
    static let emotionCompletionBackgroundGraphic = UIImage(named: "emotion_background_graphic", in: bundle, with: nil)
    static let emotionCompletionGroundGraphic = UIImage(named: "emotion_ground_graphic", in: bundle, with: nil)
    static let pomoLeftHandGraphic = UIImage(named: "marble_pomo_left_hand_graphic", in: bundle, with: nil)
    static let pomoRightHandGraphic = UIImage(named: "marble_pomo_right_hand_graphic", in: bundle, with: nil)
    static let marblePomoGraphic = UIImage(named: "marblePomo_graphic", in: bundle, with: nil)

    // MARK: - Report
    static let loadingFomoGraphic = UIImage(named: "loading_fomo_graphic", in: bundle, with: nil)
    static let successFomoGraphic = UIImage(named: "success_fomo_graphic", in: bundle, with: nil)
}
