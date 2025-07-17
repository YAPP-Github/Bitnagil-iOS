//
//  BitnagilIcon.swift
//  Presentation
//
//  Created by 최정인 on 7/6/25.
//

import UIKit

enum BitnagilIcon {
    private static var bundle: Bundle {
        return Bundle(for: IntroView.self)
    }

    static let kakaoIcon = UIImage(named: "kakao_icon", in: bundle, with: nil)
    static let appleIcon = UIImage(named: "apple_icon", in: bundle, with: nil)
    static let checkIcon = UIImage(named: "check_icon", in: bundle, with: nil)?.withRenderingMode(.alwaysTemplate)

    // MARK: - Tab Bar Icons
    static let homeFillIcon = UIImage(named: "home_fill_icon", in: bundle, with: nil)
    static let homeEmptyIcon = UIImage(named: "home_empty_icon", in: bundle, with: nil)

    static let recommendFillIcon = UIImage(named: "recommend_fill_icon",in: bundle, with: nil)
    static let recommendEmptyIcon = UIImage(named: "recommend_empty_icon", in: bundle, with: nil)

    static let reportFillIcon = UIImage(named: "report_fill_icon", in: bundle, with: nil)?.withRenderingMode(.alwaysOriginal)
    static let reportEmptyIcon = UIImage(named: "report_empty_icon", in: bundle, with: nil)?.withRenderingMode(.alwaysOriginal)

    static let mypageFillIcon = UIImage(named: "mypage_fill_icon", in: bundle, with: nil)
    static let mypageEmptyIcon = UIImage(named: "mypage_empty_icon", in: bundle, with: nil)
}
