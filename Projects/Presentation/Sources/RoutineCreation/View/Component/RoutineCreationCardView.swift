//
//  RoutineCreationCardView.swift
//  Presentation
//
//  Created by 이동현 on 8/11/25.
//

import SnapKit
import UIKit

fileprivate enum Layout {
    static let edgeSpacing: CGFloat = 18
    static let titleImageSize: CGFloat = 24
    static let titleImageTrailingSpacing: CGFloat = 15
    static let titleLabelLargeHeight: CGFloat = 24
    static let titleLabelSmallHeight: CGFloat = 20
    static let titleLabelTrailingSpacing: CGFloat = 5
    static let placeHolderLabelHeight: CGFloat = 20
    static let subTitleLabelHeight: CGFloat = 24
    static let contentLabelStackViewSpacing: CGFloat = 1
    static let infoImageSize: CGFloat = 16
    static let asteriskImageSize: CGFloat = 12
    static let chevronDownImageWidth: CGFloat = 20
    static let chevronDownImageHeight: CGFloat = 20
    static let chevronDownImageTrailingSpacing: CGFloat = 28
    static let divideLineTopSpacing: CGFloat = 14
    static let divideLineHeight: CGFloat = 1
    static let contentViewHeight: CGFloat = 0
}

final class RoutineCreationCardView<ContentView: UIView & RoutineCreationExpandable>: UIView, UIGestureRecognizerDelegate {
    private let titleImageView = UIImageView()
    private let labelStackView = UIStackView()
    private let titleLabel = UILabel()
    private let placeHolderLabel = UILabel()
    private let infoImageView = UIImageView()
    private let asteriskImageView = UIImageView()
    private let chevronImageView = UIImageView()
    private let divideLine = UIView()
    private let contentView = ContentView()
    private var labelStackViewBottomConstraint: Constraint?
    public var onAction: ((ContentView.Action) -> Void)? {
        didSet { contentView.action = onAction }
    }

    init(
        title: String,
        placeHolder: String,
        titleImage: UIImage?,
        withInfoImage: Bool,
        withAsteriskImage: Bool
    ) {
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()

        titleLabel.text = title
        placeHolderLabel.text = placeHolder
        titleImageView.image = titleImage
        infoImageView.isHidden = !withInfoImage
        asteriskImageView.isHidden = !withAsteriskImage
        divideLine.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(
        image: UIImage,
        title: String,
        contents: [String]
    ) {
        titleImageView.image = image
        titleLabel.text = title
    }

    private func configureAttribute() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.delegate = self
        addGestureRecognizer(tapGesture)

        backgroundColor = BitnagilColor.gray99
        layer.cornerRadius = 12
        layer.masksToBounds = true

        labelStackView.spacing = Layout.contentLabelStackViewSpacing
        labelStackView.axis = .vertical
        labelStackView.distribution = .fill
        labelStackView.alignment = .leading

        titleLabel.font = BitnagilFont.init(style: .body1, weight: .semiBold).font
        titleLabel.textColor = .black

        placeHolderLabel.font = BitnagilFont.init(style: .body2, weight: .medium).font
        placeHolderLabel.textColor = BitnagilColor.gray70

        infoImageView.image = BitnagilIcon.informationIcon
        asteriskImageView.image = BitnagilIcon.asteriskIcon
        chevronImageView.image = BitnagilIcon.chevronIcon(direction: .down)?.withRenderingMode(.alwaysTemplate)
        chevronImageView.tintColor = BitnagilColor.gray30

        divideLine.backgroundColor = BitnagilColor.gray96

        contentView.isHidden = true
        contentView.action = { [weak self] in
            self?.onAction?($0)
        }
    }

    private func configureLayout() {
        addSubview(titleImageView)
        addSubview(labelStackView)
        addSubview(asteriskImageView)
        addSubview(infoImageView)
        addSubview(contentView)
        addSubview(chevronImageView)
        addSubview(divideLine)

        labelStackView.addArrangedSubview(titleLabel)
        labelStackView.addArrangedSubview(placeHolderLabel)

        titleImageView.snp.makeConstraints { make in
            make.centerY.equalTo(labelStackView)
            make.leading.equalToSuperview().offset(Layout.edgeSpacing)
            make.size.equalTo(Layout.titleImageSize)
        }

        labelStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Layout.edgeSpacing)
            make.leading.equalTo(titleImageView.snp.trailing).offset(Layout.titleImageTrailingSpacing)
            make.trailing.equalToSuperview().offset(-Layout.edgeSpacing)
            labelStackViewBottomConstraint = make.bottom.equalToSuperview()
                .offset(-Layout.edgeSpacing)
                .priority(.medium)
                .constraint
        }

        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(Layout.titleLabelLargeHeight)
        }

        placeHolderLabel.snp.makeConstraints { make in
            make.height.equalTo(Layout.placeHolderLabelHeight)
        }

        infoImageView.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(Layout.titleLabelTrailingSpacing)
            make.centerY.equalTo(titleLabel)
            make.size.equalTo(Layout.infoImageSize)
        }

        asteriskImageView.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(Layout.titleLabelTrailingSpacing)
            make.centerY.equalTo(titleLabel)
            make.size.equalTo(Layout.asteriskImageSize)
        }

        chevronImageView.snp.makeConstraints { make in
            make.centerY.equalTo(titleImageView)
            make.height.equalTo(Layout.chevronDownImageHeight)
            make.width.equalTo(Layout.chevronDownImageWidth)
            make.trailing.equalToSuperview().offset(-Layout.chevronDownImageTrailingSpacing)
        }

        divideLine.snp.makeConstraints { make in
            make.top.equalTo(labelStackView.snp.bottom).offset(Layout.divideLineTopSpacing)
            make.horizontalEdges.equalToSuperview().inset(Layout.edgeSpacing)
            make.height.equalTo(Layout.divideLineHeight)
        }

        contentView.snp.makeConstraints { make in
            make.top.equalTo(divideLine.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview().offset(-Layout.edgeSpacing)
        }
    }

    func configure(subTitles: [String]) {
        labelStackView.arrangedSubviews.dropFirst(2).forEach { subview in
            labelStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }

        for text in subTitles {
            let label = UILabel()
            label.text = text
            label.font = BitnagilFont(style: .body1, weight: .semiBold).font
            label.textColor = BitnagilColor.gray10
            label.numberOfLines = 1

            labelStackView.addArrangedSubview(label)
            label.snp.makeConstraints { make in
                make.height.equalTo(Layout.subTitleLabelHeight)
            }
        }

        titleLabel.snp.updateConstraints { make in
            make.height.equalTo(subTitles.isEmpty ? Layout.titleLabelLargeHeight : Layout.titleLabelSmallHeight)
        }

        updateHeaderVisibility()
        setNeedsLayout()
    }

    func configure(dependencies: ContentView.Dependency) {
        contentView.configure(dependency: dependencies)
    }

    @objc private func handleTap(_ gestureRecognizer: UIGestureRecognizer) {
        let location = gestureRecognizer.location(in: self)

        if location.y < labelStackView.frame.maxY {
            toggleExpand()
        }
    }

    private func configureContents(contents: [String]) {
        defer {
            updateHeaderVisibility()
            setNeedsLayout()
        }

        guard !contents.isEmpty else { return }

        labelStackView
            .arrangedSubviews
            .dropFirst(2)
            .forEach { $0.removeFromSuperview() }

        contents.forEach {
            let label = UILabel()
            label.text = $0
            label.font = BitnagilFont.init(style: .body1, weight: .semiBold).font
            label.textColor = .black

            labelStackView.addArrangedSubview(label)
            label.snp.makeConstraints { make in
                make.height.equalTo(Layout.subTitleLabelHeight)
            }
        }
    }

    private func toggleExpand() {
        let isExpanded = !(labelStackViewBottomConstraint?.isActive ?? false)
        let nextExpandedState = !isExpanded

        if nextExpandedState {
            labelStackViewBottomConstraint?.isActive = false
            contentView.isHidden = false
            divideLine.isHidden = false
            chevronImageView.image = BitnagilIcon.chevronIcon(direction: .up)
        } else {
            labelStackViewBottomConstraint?.isActive = true
            contentView.isHidden = true
            divideLine.isHidden = true
            chevronImageView.image = BitnagilIcon.chevronIcon(direction: .down)
        }

        contentView.setExpanded(expanded: nextExpandedState)
        updateHeaderVisibility()

        self.layoutIfNeeded()
    }

    private func updateHeaderVisibility() {
        let arranged = labelStackView.arrangedSubviews
        let subtitles = arranged.dropFirst(2)
        let hasSubtitles = !subtitles.isEmpty
        let isExpanded = !contentView.isHidden
        let titleHeight: CGFloat = {
            if isExpanded { return Layout.titleLabelLargeHeight }
            return hasSubtitles ? Layout.titleLabelSmallHeight : Layout.titleLabelLargeHeight
        }()

        placeHolderLabel.isHidden = isExpanded || hasSubtitles
        subtitles.forEach { $0.isHidden = isExpanded }

        titleLabel.snp.updateConstraints { make in
            make.height.equalTo(titleHeight)
        }

        if titleHeight == Layout.titleLabelLargeHeight {
            titleLabel.font = isExpanded ? BitnagilFont.init(style: .body2, weight: .semiBold).font : BitnagilFont.init(style: .body1, weight: .semiBold).font
            titleLabel.textColor = BitnagilColor.gray10
        } else {
            titleLabel.font = BitnagilFont.init(style: .body2, weight: .medium).font
            titleLabel.textColor = BitnagilColor.gray50
        }
    }
}
