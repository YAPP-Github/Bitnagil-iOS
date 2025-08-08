//
//  UserDefaultsStorage.swift
//  DataSource
//
//  Created by 최정인 on 7/26/25.
//

import Foundation

final class UserDefaultsStorage {
    static let shared = UserDefaultsStorage()
    private let userDefaults: UserDefaults = .standard

    private init() { }

    func save(_ value: Any?, forKey key: String) -> Bool {
        userDefaults.set(value, forKey: key)
        return userDefaults.object(forKey: key) != nil
    }

    func load<T>(forKey key: String) -> T? {
        userDefaults.object(forKey: key) as? T
    }

    func remove(forKey key: String) -> Bool {
        userDefaults.removeObject(forKey: key)
        return userDefaults.object(forKey: key) == nil
    }
}
