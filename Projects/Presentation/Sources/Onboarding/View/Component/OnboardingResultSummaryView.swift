//
//  OnboardingResultSummaryView.swift
//  Presentation
//
//  Created by 최정인 on 8/11/25.
//

import Domain
import SnapKit
import UIKit

final class OnboardingResultSummaryView: UIView {
    private enum Layout {
        static let orderImageViewSize: CGFloat = 24
        static let resultSummaryLabelLeadingSpacing: CGFloat = 14
        static let resultSummaryLabelHeight: CGFloat = 28
    }

    private let orderImageView = UIImageView()
    private let resultSummaryLabel = UILabel()
    private let grayLine = UIImageView()

    init(onboardingType: OnboardingType?, highlightText: String) {
        super.init(frame: .zero)
        configureAttribute(onboardingType: onboardingType, highlightText: highlightText)
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureAttribute(onboardingType: OnboardingType?, highlightText: String) {
        switch onboardingType {
        case .time:
            orderImageView.image = BitnagilIcon.circleOneIcon
        case .feeling:
            orderImageView.image = BitnagilIcon.circleTwoIcon
        case .outdoor:
            orderImageView.image = BitnagilIcon.circleThreeIcon
        default:
            orderImageView.isHidden = true
        }

        let baseText = baseText(onboardingType: onboardingType, highlightText: highlightText)
        resultSummaryLabel.attributedText = NSAttributedString.highlighted(text: baseText, highlightText: highlightText)

        grayLine.image = BitnagilGraphic.onboardingGrayLine
    }

    private func configureLayout() {
        addSubview(orderImageView)
        addSubview(resultSummaryLabel)
        addSubview(grayLine)

        orderImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(Layout.orderImageViewSize)
        }

        resultSummaryLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(orderImageView.snp.trailing).offset(Layout.resultSummaryLabelLeadingSpacing)
            make.height.equalTo(Layout.resultSummaryLabelHeight)
        }

        grayLine.snp.makeConstraints { make in
            make.leading.equalTo(resultSummaryLabel)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    private func baseText(onboardingType: OnboardingType?, highlightText: String) -> String {
        switch onboardingType {
        case .time:
            return timeResultBaseText(highlightText: highlightText)

        case .feeling:
            if highlightText.filter({ $0 == "," }).count >= 2 {
                return "\(highlightText)을"
            } else {
                return "\(highlightText)을 원하는 중이에요"
            }

        case .outdoor:
            return "\(highlightText)을 목표로 해볼게요!"

        default:
            return "원하는 중이에요"
        }
    }

    private func timeResultBaseText(highlightText: String) -> String {
        switch highlightText {
        case "아침루틴":
            return "아침루틴을 만들고 싶고"
        case "저녁루틴":
            return "저녁루틴을 만들고 싶고"
        case "전체루틴":
            return "전체루틴을 회복하고 싶고"
        default:
            return ""
        }
    }
}
