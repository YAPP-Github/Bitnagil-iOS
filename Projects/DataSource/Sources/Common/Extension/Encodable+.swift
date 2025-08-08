//
//  Encodable+.swift
//  DataSource
//
//  Created by 이동현 on 8/3/25.
//

import Foundation

extension Encodable {
    var dictionary: [String: Any] {
        guard
            let data = try? JSONEncoder().encode(self),
            let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return [:] }
        return dictionary
    }
}
