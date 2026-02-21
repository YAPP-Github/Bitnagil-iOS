//
//  DomainError.swift
//  Domain
//
//  Created by 이동현 on 2/17/26.
//

public enum DomainError: Error, Equatable {
    case requireRetry
    case business(String)
    case unknown
}
