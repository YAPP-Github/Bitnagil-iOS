//
//  UserDataRepository.swift
//  DataSource
//
//  Created by 이동현 on 7/20/25.
//

import Domain
import Foundation

final class UserDataRepository: UserDataRepositoryProtocol {
    private let userDefaultsStorage = UserDefaultsStorage.shared
    
    func loadNickname() throws -> String {
        guard let nickname: String = userDefaultsStorage.load(forKey: UserDefaultsKey.nickname.rawValue) else {
            throw UserError.nicknameLoadFailed
        }

        return nickname
    }
}

