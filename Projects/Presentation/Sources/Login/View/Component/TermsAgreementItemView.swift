//
//  TermsAgreementItemView.swift
//  Presentation
//
//  Created by 최정인 on 7/7/25.
//

import Domain
import SnapKit
import UIKit

protocol TermsAgreementItemViewDelegate: AnyObject {
    func termsAgreementItemView(_ sender: TermsAgreementItemView, didToggleCheckFor termType: TermsType)
    func termsAgreementItemView(_ sender: TermsAgreementItemView, didTapMoreButtonFor termType: TermsType)
}

final class TermsAgreementItemView: UIView {

    private enum Layout {
        static let checkButtonLeadingSpacing: CGFloat = 20
        static let checkButtonSize: CGFloat = 16
        static let labelLeadingSpacing: CGFloat = 20
        static let moreButtonTrailingSpacing: CGFloat = 24
    }

    private let checkButton = UIButton()
    private let agreementLable = UILabel()
    private let moreButton = UIButton()

    private var termType: TermsType
    private var isAgreed: Bool = false {
        didSet {
            updateAttribute()
        }
    }
    weak var delegate: TermsAgreementItemViewDelegate?

    init(termType: TermsType) {
        self.termType = termType
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        checkButton.setImage(BitnagilIcon.checkIcon, for: .normal)
        checkButton.tintColor = BitnagilColor.navy100
        checkButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.isAgreed.toggle()
            self.delegate?.termsAgreementItemView(self, didToggleCheckFor: self.termType)
        }, for: .touchUpInside)

        agreementLable.attributedText = BitnagilFont(style: .body2, weight: .medium).attributedString(text: termType.title)
        agreementLable.textColor = BitnagilColor.gray50

        let title = BitnagilFont(style: .captionUnderline1, weight: .semiBold).attributedString(text: "더보기")
        moreButton.setAttributedTitle(title, for: .normal)
        moreButton.setTitleColor(BitnagilColor.gray50, for: .normal)
        moreButton.isHidden = termType.link == nil
        moreButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.delegate?.termsAgreementItemView(self, didTapMoreButtonFor: self.termType)
        }, for: .touchUpInside)
    }

    private func configureLayout() {
        addSubview(checkButton)
        addSubview(agreementLable)
        addSubview(moreButton)

        checkButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Layout.checkButtonLeadingSpacing)
            make.centerY.equalToSuperview()
            make.size.equalTo(Layout.checkButtonSize)
        }

        agreementLable.snp.makeConstraints { make in
            make.leading.equalTo(checkButton.snp.trailing).offset(Layout.labelLeadingSpacing)
            make.centerY.equalToSuperview()
        }

        moreButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Layout.moreButtonTrailingSpacing)
            make.centerY.equalToSuperview()
        }
    }

    private func updateAttribute() {
        checkButton.tintColor = isAgreed ? BitnagilColor.navy500 : BitnagilColor.navy100
    }

    func updateState(isAgreed: Bool) {
        self.isAgreed = isAgreed
    }
}
