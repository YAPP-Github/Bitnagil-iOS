//
//  AppVersionDTO.swift
//  DataSource
//
//  Created by 이동현 on 8/5/25.
//

struct AppVersionDTO: Codable {
    let resultCount: Int
    let results: [AppStoreResultDTO]
}

struct AppStoreResultDTO: Codable {
    let version: String
}
