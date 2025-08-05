//
//  AppConfigRepositoryProtocol.swift
//  Domain
//
//  Created by 이동현 on 8/5/25.
//

public protocol AppConfigRepositoryProtocol {
    func fetchAppVersion() async throws -> String?
}
