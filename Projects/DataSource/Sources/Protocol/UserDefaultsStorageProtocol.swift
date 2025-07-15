//
//  UserDefaultsStorageProtocol.swift
//  DataSource
//
//  Created by 반성준 on 6/25/25.
//

import Foundation

public protocol UserDefaultsStorageProtocol {
    func save(_ value: Any?, forKey key: String) -> Bool
    func load<T>(forKey key: String) -> T?
    func remove(forKey key: String) -> Bool
}
