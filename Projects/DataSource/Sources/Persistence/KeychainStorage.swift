//
//  KeychainStorage.swift
//  DataSource
//
//  Created by 최정인 on 7/26/25.
//

import Foundation

final class KeychainStorage {
    static let shared = KeychainStorage()
    private let service: String = Bundle.main.bundleIdentifier ?? "DefaultService"

    private init() { }

    func save(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else {
            return false
        }

        var query = baseQuery(for: key)

        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        if status == errSecItemNotFound {
            for (attributeKey, attributeValue) in attributes {
                query[attributeKey] = attributeValue
            }
            return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
        }

        return status == errSecSuccess
    }

    func load(forKey key: String) -> String? {
        var query = baseQuery(for: key)
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess,
           let data = result as? Data {
            return String(data: data, encoding: .utf8)
        }

        return nil
    }

    func remove(forKey key: String) -> Bool {
        let query = baseQuery(for: key)
        let status = SecItemDelete(query as CFDictionary)

        return status == errSecSuccess || status == errSecItemNotFound
    }

    private func baseQuery(for key: String) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        return query
    }
}
