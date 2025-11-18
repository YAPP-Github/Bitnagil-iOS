//
//  ReportEntity.swift
//  Domain
//
//  Created by 이동현 on 11/9/25.
//

public struct ReportEntity {
    let id: Int
    let title: String
    let date: String?
    let type: ReportType
    let progress: ReportProgress
    let content: String?
    let location: LocationEntity
    let photoUrls: [String]
}
