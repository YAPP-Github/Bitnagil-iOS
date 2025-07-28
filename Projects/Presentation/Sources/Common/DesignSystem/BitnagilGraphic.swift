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
    
    static let introGraphic = UIImage(named: "IntroGraphic", in: bundle, with: nil)

    // MARK: - Emotion Orb
    static let calmOrb = UIImage(named: "calm_orb", in: bundle, with: nil)
    static let lethargyOrb = UIImage(named: "lethargy_orb", in: bundle, with: nil)
    static let vitalityOrb = UIImage(named: "vitality_orb", in: bundle, with: nil)
    static let anxietyOrb = UIImage(named: "anxiety_orb", in: bundle, with: nil)
    static let satisfiedOrb = UIImage(named: "satisfied_orb", in: bundle, with: nil)
    static let tiredOrb = UIImage(named: "tired_orb", in: bundle, with: nil)
}
