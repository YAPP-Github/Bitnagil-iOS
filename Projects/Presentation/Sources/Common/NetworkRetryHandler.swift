//
//  NetworkRetryHandler.swift
//  Presentation
//
//  Created by 이동현 on 2/17/26.
//
import Combine

final class NetworkRetryHandler: NetworkRetryCapable {
    let networkErrorActionSubject = CurrentValueSubject<(() -> Void)?, Never>(nil)
}
