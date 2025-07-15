//
//  LogoutUseCaseProtocol.swift
//  Domain
//
//  Created by 최정인 on 7/4/25.
//

public protocol LogoutUseCaseProtocol {
    /// 로그아웃을 진행합니다.
    func logout() async throws

    // TODO: 추후 reissue 어디로 가야 하나 ..
    /// 토큰 재발급을 진행합니다.
    func reissueToken() async throws
}
