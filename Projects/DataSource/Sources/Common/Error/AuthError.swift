//
//  AuthError.swift
//  DataSource
//
//  Created by 최정인 on 6/30/25.
//

enum AuthError: Error, CustomStringConvertible {
    case kakaoTokenFetchFailed
    case tokenSaveFailed
    case tokenLoadFailed
    case tokenRemoveFailed
    case nicknameSaveFailed
    case nicknameLoadFailed
    case nicknameRemoveFailed
    case invalidUserData
    case unknown(Error)

    public var description: String {
        switch self {
        case .kakaoTokenFetchFailed:
            return "카카오 토큰을 가져오는데 실패했습니다."
        case .tokenSaveFailed:
            return "토큰 저장에 실패했습니다."
        case .tokenLoadFailed:
            return "토큰 불러오기에 실패했습니다."
        case .tokenRemoveFailed:
            return "토큰 삭제에 실패했습니다."
        case .nicknameSaveFailed:
            return "닉네임 저장에 실패했습니다."
        case .nicknameLoadFailed:
            return "닉네임 불러오기에 실패했습니다."
        case .nicknameRemoveFailed:
            return "닉네임 삭제에 실패했습니다."
        case .invalidUserData:
            return "서버 응답에 사용자 정보가 포함되어 있지 않습니다."
        case .unknown(let error):
            return "알 수 없는 에러가 발생했습니다. \(error.localizedDescription)"
        }
    }
}
