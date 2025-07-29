//
//  UserDataUseCaseProtocol.swift
//  Domain
//
//  Created by 최정인 on 7/30/25.
//

public protocol UserDataUseCaseProtocol {
    func loadNickname() async throws -> String
}
