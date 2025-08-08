//
//  TokenManager.swift
//  DataSource
//
//  Created by 최정인 on 7/26/25.
//

final class TokenManager {
    static let shared = TokenManager()
    private let keychainStorage = KeychainStorage.shared

    private init() { }

    func loadToken(tokenType: TokenType) throws -> String {
        guard let token: String = keychainStorage.load(forKey: tokenType.rawValue)
        else { throw TokenError.tokenLoadFailed }
        return token
    }

    func saveToken(token: String, tokenType: TokenType) throws {
        guard keychainStorage.save(token, forKey: tokenType.rawValue)
        else { throw TokenError.tokenSaveFailed }
    }

    func removeToken() throws {
        guard
            keychainStorage.remove(forKey: TokenType.accessToken.rawValue),
            keychainStorage.remove(forKey: TokenType.refreshToken.rawValue)
        else { throw TokenError.tokenRemoveFailed }
    }
}
