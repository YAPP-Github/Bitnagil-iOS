//
//  ReportEntity.swift
//  Domain
//
//  Created by 이동현 on 11/9/25.
//

public struct ReportEntity {
    public let id: Int?
    public let title: String
    public let date: String?
    public let type: ReportType
    public let progress: ReportProgress
    public let content: String?
    public let location: LocationEntity
    public let thumbnailURL: String?
    public let photoURLs: [String]

    public init(
        id: Int?,
        title: String,
        date: String?,
        type: ReportType,
        progress: ReportProgress,
        content: String?,
        location: LocationEntity,
        thumbnailURL: String?,
        photoUrls: [String]
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.type = type
        self.progress = progress
        self.content = content
        self.location = location
        self.thumbnailURL = thumbnailURL
        self.photoURLs = photoUrls
    }
}
