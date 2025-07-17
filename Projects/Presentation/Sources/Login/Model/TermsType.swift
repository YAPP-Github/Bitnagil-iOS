//
//  TermsType.swift
//  Presentation
//
//  Created by 최정인 on 7/8/25.
//

import Domain
import Foundation

extension TermsType {
    var title: String {
        switch self {
        case .service: "(필수) 서비스 이용약관 동의"
        case .privacy: "(필수) 개인정보 수집·이용 동의"
        case .age: "(필수) 만 14세 이상입니다."
        }
    }

    var link: URL? {
        switch self {
        case .service: URL(string: "https://yapp-workspace.notion.site/2282106a0e84804cb283e44f24ecc567")
        case .privacy: URL(string: "https://yapp-workspace.notion.site/22a2106a0e848090864dc02fba31de34")
        case .age: nil
        }
    }
}
