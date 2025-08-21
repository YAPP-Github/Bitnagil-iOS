//
//  BitnagilIcon.swift
//  Presentation
//
//  Created by 최정인 on 7/6/25.
//

import UIKit

enum BitnagilIcon {
    private static var bundle: Bundle {
        return Bundle(for: IntroViewController.self)
    }

    // MARK: - Common Icons
    static let backButtonIcon = UIImage(named: "back_button_icon", in: bundle, with: nil)
    static let plusIcon = UIImage(named: "plus_icon", in: bundle, with: nil)?.withRenderingMode(.alwaysTemplate)

    // MARK: - Login Icons
    static let kakaoIcon = UIImage(named: "kakao_icon", in: bundle, with: nil)
    static let appleIcon = UIImage(named: "apple_icon", in: bundle, with: nil)

    // MARK: - Terms Agreement Icons
    static let checkIcon = UIImage(named: "check_icon", in: bundle, with: nil)?.withRenderingMode(.alwaysTemplate)
    static let smallCheckIcon = UIImage(named: "small_check_icon", in: bundle, with: nil)?.withRenderingMode(.alwaysTemplate)

    // MARK: - Onboarding Icons
    static let orangeCheckedCircleIcon = UIImage(named: "orange_checked_circle_icon", in: bundle, with: nil)
    static let circleOneIcon = UIImage(named: "circle_one_icon", in: bundle, with: nil)
    static let circleTwoIcon = UIImage(named: "circle_two_icon", in: bundle, with: nil)
    static let circleThreeIcon = UIImage(named: "circle_three_icon", in: bundle, with: nil)

    // MARK: - Home Icons
    static let helpIcon = UIImage(named: "help_icon", in: bundle, with: nil)
    static let alarmIcon = UIImage(named: "alarm_icon", in: bundle, with: nil)
    static let alarmWithBadgeIcon = UIImage(named: "alarm_badge_icon", in: bundle, with: nil)
    static let chevronLeftIcon = UIImage(named: "chevron_left_icon", in: bundle, with: nil)
    static let chevronRightIcon = UIImage(named: "chevron_right_icon", in: bundle, with: nil)
    static let checkedCircleIcon = UIImage(named: "checked_circle_icon", in: bundle, with: nil)
    static let uncheckedCircleIcon = UIImage(named: "unchecked_circle_icon", in: bundle, with: nil)
    static let checkedCircleSmallIcon = UIImage(named: "checked_circle_small_icon", in: bundle, with: nil)
    static let uncheckedCircleSmallIcon = UIImage(named: "unchecked_circle_small_icon", in: bundle, with: nil)

    static let chevronIcon = UIImage(named: "chevron_icon", in: bundle, with: nil)
    static func chevronIcon(direction: Direction) -> UIImage? {
        return BitnagilIcon.chevronIcon?.rotate(degrees: direction.rotation)?.withRenderingMode(.alwaysTemplate)
    }
    static let informationIcon = UIImage(named: "information_icon", in: bundle, with: nil)
    static let addRoutineIcon = UIImage(named: "add_routine_icon", in: bundle, with: nil)
    static let divideLineIcon = UIImage(named: "divide_line_icon", in: bundle, with: nil)
    static let clearIcon = UIImage(named: "clear_icon", in: bundle, with: nil)

    // MARK: - Routine Category Icons
    static let wakeupIcon = UIImage(named: "wakeup_icon", in: bundle, with: nil)
    static let shineIcon = UIImage(named: "shine_icon", in: bundle, with: nil)
    static let growIcon = UIImage(named: "grow_icon", in: bundle, with: nil)
    static let outsideIcon = UIImage(named: "outside_icon", in: bundle, with: nil)
    static let connectIcon = UIImage(named: "connect_icon", in: bundle, with: nil)
    static let restIcon = UIImage(named: "rest_icon", in: bundle, with: nil)

    // MARK: - Tab Bar Icons
    static let homeIcon = UIImage(named: "home_fill_icon", in: bundle, with: nil)
    static let recommendIcon = UIImage(named: "recommend_fill_icon",in: bundle, with: nil)
    static let reportFillIcon = UIImage(named: "report_fill_icon", in: bundle, with: nil)
    static let reportEmptyIcon = UIImage(named: "report_empty_icon", in: bundle, with: nil)
    static let mypageIcon = UIImage(named: "mypage_fill_icon", in: bundle, with: nil)

    // MARK: - Mypage Icons
    static let settingIcon = UIImage(named: "setting_icon", in: bundle, with: nil)
    static let exclamationFilledIcon = UIImage(named: "exclamation_filled_icon", in: bundle, with: nil)

    // MARK: - Routine Creation Icons
    static let asteriskIcon = UIImage(named: "asterisk_icon", in: bundle, with: nil)
    static let deleteIcon = UIImage(named: "delete_icon", in: bundle, with: nil)
    static let uncheckedIcon = UIImage(named: "unchecked_icon", in: bundle, with: nil)
    static let checkedIcon = UIImage(named: "checked_icon", in: bundle, with: nil)
    static let routineCreationIcon = UIImage(named: "routine_creation_icon", in: bundle, with: nil)
    static let routineTimeIcon = UIImage(named: "routine_creation_time_icon", in: bundle, with: nil)
    static let routineListIcon = UIImage(named: "routine_creation_list_icon", in: bundle, with: nil)
    static let routineDateIcon = UIImage(named: "routine_creation_date", in: bundle, with: nil)
    static let routineRepeatIcon = UIImage(named: "routine_creation_repeat_icon", in: bundle, with: nil)
    static let oneIcon = UIImage(named: "routine_creation_one_icon", in: bundle, with: nil)
    static let twoIcon = UIImage(named: "routine_creation_two_icon", in: bundle, with: nil)
    static let threeIcon = UIImage(named: "routine_creation_three_icon", in: bundle, with: nil)

    // MARK: - Routine List Icons
    static let editIcon = UIImage(named: "edit_icon", in: bundle, with: nil)
    static let trashIcon = UIImage(named: "trash_icon", in: bundle, with: nil)
    static let closeIcon = UIImage(named: "close_icon", in: bundle, with: nil)
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
