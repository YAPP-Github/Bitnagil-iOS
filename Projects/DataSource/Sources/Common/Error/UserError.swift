//
//  UserError.swift
//  DataSource
//
//  Created by 이동현 on 7/20/25.
//

enum UserError: Error, CustomStringConvertible {
    case accessTokenLoadFailed
    case nicknameLoadFailed
    case unknown(error: Error)


    var description: String {
        switch self {
        case .accessTokenLoadFailed:
            return "토큰 불러오기에 실패했습니다."
        case .nicknameLoadFailed:
            return "닉네임 불러오기에 실패했습니다."
        case .unknown(let error):
            return "알 수 없는 에러가 발생했습니다. \(error.localizedDescription)"
        }
    }
}
