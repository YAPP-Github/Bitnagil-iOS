//
//  YouthPolicyTab.swift
//  Presentation
//

enum YouthPolicyTab: CaseIterable {
    case entire
    case bookmarked

    var description: String {
        switch self {
        case .entire:
            "전체"
        case .bookmarked:
            "찜한 공고"
        }
    }

    /// 탭 이름 옆에 공고 개수를 노출할지 여부입니다. 전체 탭만 노출합니다.
    var showsCount: Bool {
        switch self {
        case .entire:
            true
        case .bookmarked:
            false
        }
    }
}
