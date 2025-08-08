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
    static let plusIcon = UIImage(named: "plus_icon", in: bundle, with: nil)?.withRenderingMode(.alwaysTemplate)
    static let chevronIcon = UIImage(named: "chevron_icon", in: bundle, with: nil)
    static func chevronIcon(direction: Direction) -> UIImage? {
        return BitnagilIcon.chevronIcon?.rotate(degrees: direction.rotation)?.withRenderingMode(.alwaysTemplate)
    }
    static let ellipsisIcon = UIImage(named: "ellipsis_icon", in: bundle, with: nil)
    static let informationIcon = UIImage(named: "information_icon", in: bundle, with: nil)
    static let sortIcon = UIImage(named: "sort_icon", in: bundle, with: nil)
    static let addRoutineIcon = UIImage(named: "add_routine_icon", in: bundle, with: nil)

    // MARK: - Tab Bar Icons
    static let homeFillIcon = UIImage(named: "home_fill_icon", in: bundle, with: nil)
    static let homeEmptyIcon = UIImage(named: "home_empty_icon", in: bundle, with: nil)

    static let recommendFillIcon = UIImage(named: "recommend_fill_icon",in: bundle, with: nil)
    static let recommendEmptyIcon = UIImage(named: "recommend_empty_icon", in: bundle, with: nil)

    static let reportFillIcon = UIImage(named: "report_fill_icon", in: bundle, with: nil)?.withRenderingMode(.alwaysOriginal)
    static let reportEmptyIcon = UIImage(named: "report_empty_icon", in: bundle, with: nil)?.withRenderingMode(.alwaysOriginal)

    static let mypageFillIcon = UIImage(named: "mypage_fill_icon", in: bundle, with: nil)
    static let mypageEmptyIcon = UIImage(named: "mypage_empty_icon", in: bundle, with: nil)

    // MARK: - Mypage Icons
    static let settingIcon = UIImage(named: "setting_icon", in: bundle, with: nil)
    static let exclamationFilledIcon = UIImage(named: "exclamation_filled_icon", in: bundle, with: nil)
    // MARK: - Routine Creation Icons
    static let asteriskIcon = UIImage(named: "asterisk_icon", in: bundle, with: nil)
    static let deleteIcon = UIImage(named: "delete_icon", in: bundle, with: nil)
    static let uncheckedIcon = UIImage(named: "unchecked_icon", in: bundle, with: nil)
    static let checkedIcon = UIImage(named: "checked_icon", in: bundle, with: nil)
    static let routineCreationIcon = UIImage(named: "routine_creation_icon", in: bundle, with: nil)

    // MARK: - Routine Detail Icons
    static let routineIcon = UIImage(named: "routine_icon", in: bundle, with: nil)
    static let subRoutineIcon = UIImage(named: "subRoutine_icon", in: bundle, with: nil)
    static let repeatIcon = UIImage(named: "repeat_icon", in: bundle, with: nil)
    static let editIcon = UIImage(named: "edit_icon", in: bundle, with: nil)
    static let trashIcon = UIImage(named: "trash_icon", in: bundle, with: nil)
}

enum Direction {
    case up
    case down
    case left
    case right

    var rotation: Float {
        switch self {
        case .up: 90
        case .down: -90
        case .left: 0
        case .right: 180
        }
    }
}
