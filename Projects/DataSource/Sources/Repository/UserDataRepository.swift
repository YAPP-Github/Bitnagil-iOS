//
//  UserDataRepository.swift
//  DataSource
//
//  Created by 이동현 on 7/20/25.
//

import Domain
import Foundation

final class UserDataRepository: UserDataRepositoryProtocol {
    private let keychainStorage = KeychainStorage.shared
    private let userDefaultsStorage = UserDefaultsStorage.shared

    // TODO: - accessToken fetch 로직 상의 후 결정
    func loadAccessToken() throws -> String {
        guard let token = keychainStorage.load(forKey: TokenType.accessToken.rawValue) else {
            throw UserError.accessTokenLoadFailed
        }

        return token
    }
    
    func loadNickname() throws -> String {
        guard let nickname: String = userDefaultsStorage.load(forKey: UserDefaultsKey.nickname.rawValue) else {
            throw UserError.nicknameLoadFailed
        }

        return nickname
    }
}

