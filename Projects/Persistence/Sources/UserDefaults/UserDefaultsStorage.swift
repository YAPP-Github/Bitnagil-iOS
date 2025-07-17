//
//  UserDefaultsStorage.swift
//  Persistence
//
//  Created by 반성준 on 6/23/25.
//

import DataSource
import Foundation

public final class UserDefaultsStorage: UserDefaultsStorageProtocol {
    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    public func save(_ value: Any?, forKey key: String) -> Bool {
        userDefaults.set(value, forKey: key)
        return userDefaults.object(forKey: key) != nil
    }

    public func load<T>(forKey key: String) -> T? {
        userDefaults.object(forKey: key) as? T
    }

    public func remove(forKey key: String) -> Bool {
        userDefaults.removeObject(forKey: key)
        return userDefaults.object(forKey: key) == nil
    }
}
