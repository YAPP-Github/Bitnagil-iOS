//
//  WithdrawUseCaseProtocol.swift
//  Domain
//
//  Created by 최정인 on 7/4/25.
//

public protocol WithdrawUseCaseProtocol {
    /// 계정 탈퇴를 진행합니다.
    func withdraw() async throws
}
