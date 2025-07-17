//
//  IntroView.swift
//  Presentation
//
//  Created by 최정인 on 7/6/25.
//

import Shared
import SnapKit
import Then
import UIKit

public final class IntroView: UIViewController {

    private enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let labelTopSpacing: CGFloat = 54
        static let graphViewTopSpacing: CGFloat = 38
        static let graphViewBottomSpacing: CGFloat = 64
        static let startButtonBottomSpacing: CGFloat = 20
        static let startButtonHeight: CGFloat = 54
    }

    private let introLabel = UILabel()
    private let graphView = UIView()
    private let startButton = PrimaryButton(buttonState: .default, buttonTitle: "시작하기")

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureAttribute()
        configureLayout()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(navigationStyle: .hidden)
    }

    private func configureAttribute() {
        introLabel.do {
            let text = "당신의 하루 리듬을 이해하고,\n작은 변화를 함께 시작해볼게요."
            $0.attributedText = BitnagilFont(style: .title2, weight: .bold).attributedString(text: text)
            $0.textAlignment = .center
            $0.textColor = BitnagilColor.navy500
            $0.numberOfLines = 2
        }

        graphView.do {
            $0.backgroundColor = BitnagilColor.gray90
        }

        startButton.addAction(UIAction { [weak self] _ in
            guard let loginViewModel = DIContainer.shared.resolve(type: LoginViewModel.self) else {
                fatalError("loginViewModel 의존성이 등록되지 않았습니다.")
            }
            let loginView = LoginView(viewModel: loginViewModel)
            self?.navigationController?.pushViewController(loginView, animated: true)
        }, for: .touchUpInside)
    }

    private func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        view.backgroundColor = .systemBackground

        view.addSubview(introLabel)
        view.addSubview(graphView)
        view.addSubview(startButton)

        introLabel.snp.makeConstraints { make in
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.trailing.equalTo(safeArea).inset(Layout.horizontalMargin)
            make.top.equalTo(safeArea).offset(Layout.labelTopSpacing)
        }

        graphView.snp.makeConstraints { make in
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.trailing.equalTo(safeArea).inset(Layout.horizontalMargin)
            make.top.equalTo(introLabel.snp.bottom).offset(Layout.graphViewTopSpacing)
            make.bottom.equalTo(startButton.snp.top).offset(-Layout.graphViewBottomSpacing)
        }

        startButton.snp.makeConstraints { make in
            make.leading.equalTo(safeArea).offset(Layout.horizontalMargin)
            make.trailing.equalTo(safeArea).inset(Layout.horizontalMargin)
            make.bottom.equalTo(safeArea).inset(Layout.startButtonBottomSpacing)
            make.height.equalTo(Layout.startButtonHeight)
        }
    }
}
