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
        case .service: URL(string: "https://complex-wombat-99f.notion.site/2025-7-20-236f4587491d8071833adfaf8115bce2")
        case .privacy: URL(string: "https://complex-wombat-99f.notion.site/2025-07-20-236f4587491d80308016eb810692d18b")
        case .age: nil
        }
    }
}
