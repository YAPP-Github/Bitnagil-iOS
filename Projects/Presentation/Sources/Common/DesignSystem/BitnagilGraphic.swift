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
}
