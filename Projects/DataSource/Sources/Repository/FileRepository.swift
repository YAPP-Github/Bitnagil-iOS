//
//  FileRepository.swift
//  DataSource
//
//  Created by 이동현 on 11/22/25.
//

import Domain
import Foundation

final class FileRepository: FileRepositoryProtocol {
    private let networkService = NetworkService.shared

    func fetchPresignedURL(prefix: String?, fileNames: [String]) async throws -> [String : String]? {
        let dtos = fileNames.map { FilePresignedConditionDTO(prefix: prefix, fileName: $0) }
        let endpoint = FilePresignedEndpoint.fetchPresignedURL(presignedConditions: dtos)

        return try await networkService.request(endpoint: endpoint, type: [String:String].self)
    }

    func uploadFile(url: String, data: Data) async throws {
        let endPoint = S3Endpoint.uploadImage(uploadURL: url, data: data)
        _ = try await networkService.request(endpoint: endPoint, type: EmptyResponseDTO.self)
    }
}
