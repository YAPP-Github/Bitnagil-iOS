//
//  TokenError.swift
//  DataSource
//
//  Created by 최정인 on 7/26/25.
//

enum TokenError: Error, CustomStringConvertible {
    case tokenSaveFailed
    case tokenLoadFailed
    case tokenRemoveFailed

    public var description: String {
        switch self {
        case .tokenSaveFailed:
            return "토큰 저장에 실패했습니다."
        case .tokenLoadFailed:
            return "토큰 불러오기에 실패했습니다."
        case .tokenRemoveFailed:
            return "토큰 삭제에 실패했습니다."
        }
    }
}
