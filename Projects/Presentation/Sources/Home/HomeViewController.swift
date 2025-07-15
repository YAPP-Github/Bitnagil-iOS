//
//  HomeViewController.swift
//  Presentation
//
//  Created by 최정인 on 6/15/25.
//

import Foundation
import Combine
import UIKit
import SnapKit
import Then
import Shared

final class HomeViewController: BaseViewController<HomeViewModel> {
    private var cancellables: Set<AnyCancellable>

    private let label = UILabel()

    override init(viewModel: HomeViewModel) {
        cancellables = []
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func configureAttribute() {
        view.backgroundColor = .blue

        label.do {
            $0.textColor = BitnagilColor.gray90
            $0.attributedText = BitnagilFont(style: .headline1, weight: .medium).attributedString(text: nil)
        }
    }

    override func configureLayout() {
        view.addSubview(label)

        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().inset(20)
            make.trailing.lessThanOrEqualToSuperview().inset(20)
        }
    }

    override func bind() {
    }
}
