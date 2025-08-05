//
//  AppConfigRepository.swift
//  DataSource
//
//  Created by 이동현 on 8/5/25.
//

import Domain
import Foundation

final class AppConfigRepository: AppConfigRepositoryProtocol {

    func fetchAppVersion() async throws -> String? {
        guard let bundleId = Bundle.main.bundleIdentifier else { return nil }
        let urlString = "https://itunes.apple.com/lookup?bundleId=\(bundleId)&country=KR"
        guard let url = URL(string: urlString) else { return nil }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(AppVersionDTO.self, from: data)
        return decoded.results.first?.version
    }
}
