//
//  ReportType.swift
//  Domain
//
//  Created by 이동현 on 11/9/25.
//

public enum ReportType: String, CaseIterable {
    case transportation = "TRANSPORTATION"
    case lamp = "LIGHTING"
    case water = "WATERFACILITY"
    case convenience = "AMENITY"
}

extension ReportType: CustomStringConvertible {
    public var description: String {
        return self.rawValue.uppercased()
    }
}
