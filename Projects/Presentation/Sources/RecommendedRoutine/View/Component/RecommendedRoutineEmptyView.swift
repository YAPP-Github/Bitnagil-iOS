//
//  RecommendedRoutineEmptyView.swift
//  Presentation
//
//  Created by 최정인 on 8/17/25.
//

import SnapKit
import UIKit

final class RecommendedRoutineEmptyView: UIView {
    private let stackView = UIStackView()
    private let mainLabel = UILabel()
    private let subLabel = UILabel()

    init() {
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureAttribute() {
        stackView.axis = .vertical
        stackView.spacing = 2

        mainLabel.text = "해당 난이도 루틴이 없어요"
        mainLabel.font = BitnagilFont(style: .subtitle1, weight: .semiBold).font
        mainLabel.textColor = BitnagilColor.gray30
        mainLabel.textAlignment = .center

        subLabel.text = "다른 난이도를 살펴보거나 루틴을 추가해 보세요."
        subLabel.font = BitnagilFont(style: .body2, weight: .regular).font
        subLabel.textColor = BitnagilColor.gray70
        subLabel.textAlignment = .center
    }

    private func configureLayout() {
        addSubview(stackView)
        [mainLabel, subLabel].forEach {
            stackView.addArrangedSubview($0)
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mainLabel.snp.makeConstraints { make in
            make.height.equalTo(28)
        }

        subLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
    }
}
