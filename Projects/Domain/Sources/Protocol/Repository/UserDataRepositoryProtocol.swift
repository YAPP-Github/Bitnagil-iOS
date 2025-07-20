//
//  UserDataRepositoryProtocol.swift
//  DataSource
//
//  Created by 이동현 on 7/20/25.
//

/// 유저의 이름, 토큰 등 유저 정보와 관련된 데이터를 가져오는 Repository
public protocol UserDataRepositoryProtocol {
    /// 저장한 accessToken을 가져옵니다.
    /// - Returns: accessToken
    func loadAccessToken() throws -> String

    /// 저장한 닉네임을 가져옵니다.
    /// - Returns: 유저 닉네임
    func loadNickname() throws -> String
}
