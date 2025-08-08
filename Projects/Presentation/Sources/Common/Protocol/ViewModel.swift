//
//  ViewModel.swift
//  Presentation
//
//  Created by 최정인 on 6/26/25.
//

public protocol ViewModel {
    associatedtype Input
    associatedtype Output

    func action(input: Input)
}
