//
//  ReportDetail.swift
//  Presentation
//
//  Created by 최정인 on 11/18/25.
//

import Domain

struct ReportDetail {
    let date: String
    let title: String
    let status: ReportProgress
    let category: ReportType
    let description: String
    let location: String
    let photoUrls: [String]
}
