//
//  DIContainer.swift
//  Shared
//
//  Created by 최정인 on 6/19/25.
//

public final class DIContainer {
    public static let shared = DIContainer()
    private var storage: [String: (DIContainer) -> Any] = [:]

    private init() { }

    public func register<T>(type: T.Type, factoryClosure: @escaping (DIContainer) -> Any) {
        storage["\(type)"] = factoryClosure
    }

    public func resolve<T>(type: T.Type) -> T? {
        guard let instance = storage["\(type)"]?(self) as? T else {
            BitnagilLogger.log(logType: .error, message: "\(type) Resolve Fail: 등록되지 않은 의존성입니다.")
            return nil
        }

        return instance
    }
}
