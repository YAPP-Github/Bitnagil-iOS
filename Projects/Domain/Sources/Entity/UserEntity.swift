//
//  UserEntity.swift
//  Domain
//
//  Created by 최정인 on 6/30/25.
//

public struct UserEntity {
    public let accessToken: String
    public let refreshToken: String
    public let userState: UserState

    public init(
        accessToken: String,
        refreshToken: String,
        userState: UserState
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.userState = userState
    }
}
