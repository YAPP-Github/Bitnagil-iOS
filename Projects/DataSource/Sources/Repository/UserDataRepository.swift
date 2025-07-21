//
//  UserDataRepository.swift
//  DataSource
//
//  Created by 이동현 on 7/20/25.
//

import Domain
import Foundation

final class UserDataRepository: UserDataRepositoryProtocol {
    private let keychainStorage: KeychainStorageProtocol
    private let userDefaultsStorage: UserDefaultsStorageProtocol

    init(keychainStorage: KeychainStorageProtocol, userDefaultsStorage: UserDefaultsStorageProtocol) {
        self.keychainStorage = keychainStorage
        self.userDefaultsStorage = userDefaultsStorage
    }

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

