//
//  UserError.swift
//  DataSource
//
//  Created by 이동현 on 7/20/25.
//

enum UserError: Error, CustomStringConvertible {
    case nicknameSaveFailed
    case nicknameLoadFailed
    case nicknameRemoveFailed
    case socialLoginTypeSaveFailed
    case socialLoginTypeLoadFailed
    case socialLoginTypeRemoveFailed
    case profileImageUrlSaveFailed
    case profileImageUrlLoadFailed
    case profileImageUrlRemoveFailed
    case unknown(error: Error)

    var description: String {
        switch self {
        case .nicknameSaveFailed:
            return "닉네임 저장 실패했습니다."
        case .nicknameLoadFailed:
            return "닉네임 불러오기에 실패했습니다."
        case .nicknameRemoveFailed:
            return "닉네임 삭제 실패했습니다."
        case .socialLoginTypeSaveFailed:
            return "소셜 로그인 타입 저장 실패했습니다."
        case .socialLoginTypeLoadFailed:
            return "소셜 로그인 타입 불러오기에 실패했습니다."
        case .socialLoginTypeRemoveFailed:
            return "소셜 로그인 타입 삭제 실패했습니다."
        case .profileImageUrlSaveFailed:
            return "유저 프로필 저장 실패했습니다."
        case .profileImageUrlLoadFailed:
            return "유저 프로필 불러오기에 실패했습니다."
        case .profileImageUrlRemoveFailed:
            return "유저 프로필 삭제 실패했습니다."
        case .unknown(let error):
            return "알 수 없는 에러가 발생했습니다. \(error.localizedDescription)"
        }
    }
}
