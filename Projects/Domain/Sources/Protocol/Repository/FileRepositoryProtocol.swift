//
//  FileRepositoryProtocol.swift
//  Domain
//
//  Created by 이동현 on 11/22/25.
//

import Foundation

public protocol FileRepositoryProtocol {
    /// 파일을 업로드할 presignedURL을 발급받습니다.
    /// - Parameters:
    ///   - prefix: 파일을 저장할 경로 prefix
    ///   - fileNames: 업로드할 파일들의 이름.
    /// - Returns: 업로드할 presignedURL (key: fileName, value: url)
    func fetchPresignedURL(prefix: String?, fileNames: [String]) async throws -> [String: String]?

    /// 주어진 url로 파일을 업로드 합니다
    /// - Parameters:
    ///   - url: 파일을 업로드할 url
    ///   - data: 업로드할 data
    func uploadFile(url: String, data: Data) async throws
}
