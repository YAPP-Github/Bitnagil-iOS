//
//  NetworkRetryCapable.swift
//  Presentation
//
//  Created by 이동현 on 2/17/26.
//

import Combine
import Domain
import Foundation

protocol NetworkRetryCapable: AnyObject {
    /// 네트워크 에러 발생 시, 재시도할 메서드를 방출하는 subject
    var networkErrorActionSubject: CurrentValueSubject<(() -> Void)?, Never> { get }

    /// 네트워크 에러 처리
    /// - Parameters:
    ///   - error: 발생한 에러
    ///   - retryAction: 재시도할 메서드
    func handleNetworkError(_ error: Error, retryAction: @escaping () -> Void)

    /// 네트워크 에러 핸들링 상태 초기화
    func clearRetryState()
}

extension NetworkRetryCapable {
    func handleNetworkError(_ error: Error, retryAction: @escaping () -> Void) {
        guard
            let domainError = error as? DomainError,
            domainError == .requireRetry
        else {
            // 네트워크 에러 문제가 아닐 경우
            return
        }

        networkErrorActionSubject.send(retryAction)
    }

    func clearRetryState() {
        networkErrorActionSubject.send(nil)
    }
}
