//
//  LogoutUseCaseProtocol.swift
//  Domain
//
//  Created by 최정인 on 7/4/25.
//

public protocol LogoutUseCaseProtocol {
    /// 로그아웃을 진행합니다.
    func logout() async throws
}
