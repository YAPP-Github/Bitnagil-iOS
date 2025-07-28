//
//  RoutineCategoryView.swift
//  Presentation
//
//  Created by 최정인 on 7/12/25.
//

import Domain
import UIKit

protocol RoutineCategoryViewDelegate: AnyObject {
    func routineCategoryView(_ sender: RoutineCategoryView, didSelectCategory category: RoutineCategoryType)
}

final class RoutineCategoryView: UIView {

    private enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let stackViewSpacing: CGFloat = 8
        static let categoryButtonHeight: CGFloat = 36
        static let categoryButtonWidth: CGFloat = 73
    }

    private let scrollView = UIScrollView()
    private let buttonStackView = UIStackView()
    private var categoryButtons: [RoutineCategoryType: RoutineCategoryButton] = [:]
    private let routineCategories = RoutineCategoryType.allCases.filter({ $0 != .outdoorReport }).sorted(by: { $0.id < $1.id })
    weak var delegate: RoutineCategoryViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        scrollView.showsHorizontalScrollIndicator = false

        buttonStackView.axis = .horizontal
        buttonStackView.spacing = Layout.stackViewSpacing

        routineCategories.forEach { type in
            let button = RoutineCategoryButton(category: type)
            button.addAction(UIAction { [weak self] _ in
                guard let self else { return }
                self.delegate?.routineCategoryView(self, didSelectCategory: type)
            }, for: .touchUpInside)
            button.tag = type.id
            categoryButtons[type] = button
        }
    }

    private func configureLayout() {
        addSubview(scrollView)
        scrollView.addSubview(buttonStackView)

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        routineCategories.forEach { type in
            guard let button = categoryButtons[type] else { return }
            buttonStackView.addArrangedSubview(button)
            button.snp.makeConstraints { make in
                make.width.equalTo(Layout.categoryButtonWidth)
                make.height.equalTo(Layout.categoryButtonHeight)
            }
        }

        buttonStackView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.leading.equalToSuperview().offset(Layout.horizontalMargin)
            make.trailing.equalToSuperview().inset(Layout.horizontalMargin)
            make.height.equalToSuperview()
        }
    }

    func updateSelectedCategory(selectedCategory: RoutineCategoryType) {
        categoryButtons.forEach { (category, button) in
            let isChecked = selectedCategory == category
            button.updateButtonState(isChecked: isChecked)
        }
    }
}
