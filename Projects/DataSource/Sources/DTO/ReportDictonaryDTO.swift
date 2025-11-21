//
//  ReportDictonaryDTO.swift
//  DataSource
//
//  Created by 최정인 on 11/21/25.
//

struct ReportDictonaryDTO: Decodable {
    let reportInfos: [String: [ReportDTO]]
}
