//
//  ReportTextView.swift
//  Presentation
//
//  Created by 이동현 on 11/8/25.
//

import SnapKit
import UIKit

protocol ReportTextViewDelegate: AnyObject {
    func reportTextViewDidChanged(_ reportTextView: ReportTextView, text: String?)
    func reportTextViewDidTapped(_ reportTextView: ReportTextView)
}

final class ReportTextView: UIView {
    enum ReportTextViewType {
        case combo
        case editable
        case nonEditable
    }

    private enum Layout {
        static let textViewHorizontalSpacing: CGFloat = 20
        static let textViewVerticalSpacing: CGFloat = 14
        static let placeholderTopSpacing: CGFloat = 15
        static let chevronImageLeadingSpacing: CGFloat = 17
        static let chevronImageTrailingSpacing: CGFloat = 19
        static let chevronImageWidth: CGFloat = 24
        static let chevronImageHeight: CGFloat = 24
    }

    private let placeholderLabel = UILabel()
    private let textView = UITextView()
    private let chevronImage = UIImageView()
    private let button = UIButton()
    weak var delegate: ReportTextViewDelegate?

    init(type: ReportTextViewType, placeholder: String?) {
        super.init(frame: .zero)
        configureAttribute(type: type, placeholder: placeholder)
        configureLayout(type: type)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute(type: ReportTextViewType, placeholder: String?) {
        backgroundColor = BitnagilColor.gray99

        placeholderLabel.textColor = BitnagilColor.gray80
        placeholderLabel.font = BitnagilFont.init(
            style: .body2,
            weight: .medium
        ).font

        chevronImage.image = BitnagilIcon
            .chevronIcon(direction: .down)?
            .withRenderingMode(.alwaysTemplate)
        chevronImage.tintColor = BitnagilColor.gray10

        button.backgroundColor = .clear
        button.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                self.delegate?.reportTextViewDidTapped(self)
            },
            for: .touchUpInside)

        textView.delegate = self
        textView.font = BitnagilFont.init(
            style: .body2,
            weight: .medium
        ).font
        textView.textColor = BitnagilColor.gray10
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
        textView.textContainer.lineFragmentPadding = 0

        if type != .editable {
            textView.isEditable = false
        }

        if let placeholder {
            placeholderLabel.text = placeholder
        }
    }

    private func configureLayout(type: ReportTextViewType) {
        addSubview(placeholderLabel)
        addSubview(textView)

        if type == .combo {
            addSubview(chevronImage)
            addSubview(button)

            chevronImage.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.trailing.equalToSuperview().inset(Layout.chevronImageTrailingSpacing)
                make.width.equalTo(Layout.chevronImageWidth)
                make.height.equalTo(Layout.chevronImageHeight)
            }

            button.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            textView.snp.makeConstraints { make in
                make.verticalEdges
                    .equalToSuperview()
                    .inset(Layout.textViewVerticalSpacing)

                make.leading
                    .equalToSuperview()
                    .offset(Layout.textViewHorizontalSpacing)

                make.trailing
                    .equalTo(chevronImage.snp.leading)
                    .inset(Layout.chevronImageLeadingSpacing)
            }
        } else {
            textView.snp.makeConstraints { make in
                make.verticalEdges
                    .equalToSuperview()
                    .inset(Layout.textViewVerticalSpacing)

                make.horizontalEdges
                    .equalToSuperview()
                    .inset(Layout.textViewHorizontalSpacing)
            }
        }

        placeholderLabel.snp.makeConstraints { make in
            make.horizontalEdges
                .equalTo(textView)

            make.top
                .equalToSuperview()
                .offset(Layout.placeholderTopSpacing)
        }
    }

    func configure(text: String) {
        textView.text = text
        updatePlaceholderVisibility()
    }

    private func updatePlaceholderVisibility() {
        placeholderLabel.isHidden = !(textView.text?.isEmpty ?? true)
    }
}

extension ReportTextView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        updatePlaceholderVisibility()
    }

    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderVisibility()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        updatePlaceholderVisibility()
        delegate?.reportTextViewDidChanged(self, text: textView.text)
    }
}
