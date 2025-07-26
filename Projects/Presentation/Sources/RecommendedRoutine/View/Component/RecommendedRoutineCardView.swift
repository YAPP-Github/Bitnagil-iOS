//
//  RecommendedRoutineCardView.swift
//  Presentation
//
//  Created by 최정인 on 7/12/25.
//

import UIKit

protocol RecommendedRoutineCardViewDelegate: AnyObject {
    func recommendedRoutineCardView(_ sender: RecommendedRoutineCardView, didTapRecommendedRoutine routine: RecommendedRoutine)
}

final class RecommendedRoutineCardView: UIView {

    private enum Layout {
        static let cornerRadius: CGFloat = 12
        static let stackViewSpacing: CGFloat = 4
        static let mainLabelHeight: CGFloat = 24
        static let subLabelHeight: CGFloat = 20
        static let horizontalMargin: CGFloat = 20
        static let plusImageSize: CGFloat = 10
        static let plusButtonSize: CGFloat = 32
    }

    private let labelStackView = UIStackView()
    private let mainLabel = UILabel()
    private let subLabel = UILabel()
    private let plusButton = UIButton()

    private let recommendedRoutine: RecommendedRoutine
    weak var delegate: RecommendedRoutineCardViewDelegate?

    init(recommendedRoutine: RecommendedRoutine) {
        self.recommendedRoutine = recommendedRoutine
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureAttribute() {
        backgroundColor = BitnagilColor.lightBlue75
        layer.cornerRadius = Layout.cornerRadius

        labelStackView.axis = .vertical
        labelStackView.spacing = Layout.stackViewSpacing

        mainLabel.text = recommendedRoutine.mainTitle
        mainLabel.font = BitnagilFont(style: .body1, weight: .semiBold).font
        mainLabel.textColor = BitnagilColor.navy500

        subLabel.text = recommendedRoutine.subTitle
        subLabel.font = BitnagilFont(style: .body2, weight: .regular).font
        subLabel.textColor = BitnagilColor.navy300

        let plusIcon = BitnagilIcon.plusIcon?
            .resizeAspectFit(to: CGSize(width: Layout.plusImageSize, height: Layout.plusImageSize))
        plusButton.setImage(plusIcon, for: .normal)
        plusButton.tintColor = BitnagilColor.navy500
        plusButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.delegate?.recommendedRoutineCardView(self, didTapRecommendedRoutine: recommendedRoutine)
        }, for: .touchUpInside)
    }

    private func configureLayout() {
        [mainLabel, subLabel].forEach { label in
            labelStackView.addArrangedSubview(label)
        }
        addSubview(labelStackView)
        addSubview(plusButton)

        mainLabel.snp.makeConstraints { make in
            make.height.equalTo(Layout.mainLabelHeight)
        }

        subLabel.snp.makeConstraints { make in
            make.height.equalTo(Layout.subLabelHeight)
        }

        labelStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Layout.horizontalMargin)
            make.centerY.equalToSuperview()
        }

        plusButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Layout.horizontalMargin)
            make.centerY.equalToSuperview()
            make.size.equalTo(Layout.plusButtonSize)
        }
    }
}
