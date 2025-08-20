//
//  LoginResponseDTO.swift
//  DataSource
//
//  Created by 최정인 on 6/30/25.
//

import Domain

struct LoginResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
    let userState: String

    enum CodingKeys: String, CodingKey {
        case accessToken
        case refreshToken
        case userState = "role"
    }
}

extension LoginResponseDTO {
    func toUserEntity() -> UserEntity {
        return UserEntity(
            accessToken: accessToken,
            refreshToken: refreshToken,
            userState: UserState(rawValue: userState) ?? .guest)
    }
}
