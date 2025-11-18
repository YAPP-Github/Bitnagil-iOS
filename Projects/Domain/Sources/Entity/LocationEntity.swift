//
//  LocationEntity.swift
//  Domain
//
//  Created by 이동현 on 11/9/25.
//

public struct LocationEntity {
    public let longitude: Double?
    public let latitude: Double?
    public let address: String?

    public init(
        longitude: Double?,
        latitude: Double?,
        address: String?
    ) {
        self.longitude = longitude
        self.latitude = latitude
        self.address = address
    }
}
