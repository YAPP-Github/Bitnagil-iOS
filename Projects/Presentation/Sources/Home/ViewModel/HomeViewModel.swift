//
//  HomeViewModel.swift
//  Presentation
//
//  Created by 최정인 on 6/26/25.
//

import Combine
import Domain

final class HomeViewModel: ViewModel {
    enum Input { }

    struct Output { }

    private(set) var output: Output

    init() {
        self.output = Output()
    }

    func action(input: Input) { }
}
