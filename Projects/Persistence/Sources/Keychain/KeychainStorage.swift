//
//  KeychainStorage.swift
//  Persistence
//
//  Created by 반성준 on 6/21/25.
//

import DataSource
import Foundation

public final class KeychainStorage: KeychainStorageProtocol {
    private let service: String
    private let accessGroup: String?

    public init(service: String? = nil, accessGroup: String? = nil) {
        self.service = service ?? Bundle.main.bundleIdentifier ?? "DefaultService"
        self.accessGroup = accessGroup
    }

    public func save(_ value: String, forKey key: String) -> Bool {
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

    public func load(forKey key: String) -> String? {
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

    public func remove(forKey key: String) -> Bool {
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

        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        return query
    }
}
