//
//  LocationRepositoryProtocol.swift
//  Domain
//
//  Created by 이동현 on 11/9/25.
//

public protocol LocationRepositoryProtocol {
    func getCoordinate() async -> LocationEntity?

    func getAddress(coordinate: LocationEntity) async throws -> LocationEntity?
}
