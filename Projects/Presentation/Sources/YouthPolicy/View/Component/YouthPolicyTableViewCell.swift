//
//  YouthPolicyTableViewCell.swift
//  Presentation
//
//  Created by 이동현 on 7/19/26.
//

import SnapKit
import UIKit

final class YouthPolicyTableViewCell: UITableViewCell {
    private enum Layout {
        static let horizontalSpacing: CGFloat = 16
        static let verticalSpacing: CGFloat = 14
        static let containerViewBottomSpacing: CGFloat = 10
        static let containerViewCornerRadius: CGFloat = 12
        static let titleLabelTopSpacing: CGFloat = 8
        static let titleLabelTrailingSpacing: CGFloat = 14
        static let periodLabelTopSpacing: CGFloat = 12
        /// 하트 아이콘의 실제 크기입니다.
        static let bookmarkIconSize: CGFloat = 24
        /// 터치 영역입니다. 아이콘보다 크게 잡아 셀 선택으로 잘못 빠지는 것을 막습니다.
        static let bookmarkButtonSize: CGFloat = 44
        /// 아이콘이 horizontalSpacing 위치에 놓이도록 버튼이 커진 만큼 당겨줍니다.
        static let bookmarkButtonTrailingSpacing: CGFloat = horizontalSpacing - (bookmarkButtonSize - bookmarkIconSize) / 2
    }

    private let containerView = UIView()
    private let badgeView = YouthPolicyBadgeView()
    private let bookmarkButton = UIButton()
    private let titleLabel = UILabel()
    private let periodLabel = UILabel()

    /// 하트 버튼을 눌렀을 때 실행할 동작입니다. 셀을 구성할 때 주입합니다.
    private var onBookmarkTap: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configureLayout()
        configureAttribute()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        onBookmarkTap = nil
    }

    private func configureAttribute() {
        backgroundColor = .clear
        selectionStyle = .none

        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = Layout.containerViewCornerRadius
        containerView.layer.masksToBounds = true

        titleLabel.numberOfLines = 2
        titleLabel.textColor = BitnagilColor.gray10
        titleLabel.font = BitnagilFont.init(style: .body2, weight: .semiBold).font
        titleLabel.textAlignment = .left

        periodLabel.textColor = BitnagilColor.gray70
        periodLabel.font = BitnagilFont.init(style: .body2, weight: .regular).font

        bookmarkButton.addAction(
            UIAction { [weak self] _ in
                self?.onBookmarkTap?()
            },
            for: .touchUpInside)
    }

    private func configureLayout() {
        contentView.addSubview(containerView)
        containerView.addSubview(badgeView)
        containerView.addSubview(bookmarkButton)
        containerView.addSubview(titleLabel)
        containerView.addSubview(periodLabel)

        containerView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()

            make.bottom
                .equalToSuperview()
                .offset(-Layout.containerViewBottomSpacing)
        }

        badgeView.snp.makeConstraints { make in
            make.leading
                .equalToSuperview()
                .offset(Layout.horizontalSpacing)

            make.top
                .equalToSuperview()
                .offset(Layout.verticalSpacing)
        }

        bookmarkButton.snp.makeConstraints { make in
            make.trailing
                .equalToSuperview()
                .offset(-Layout.bookmarkButtonTrailingSpacing)

            make.centerY.equalTo(badgeView)

            make.size.equalTo(Layout.bookmarkButtonSize)
        }

        titleLabel.snp.makeConstraints { make in
            make.top
                .equalTo(badgeView.snp.bottom)
                .offset(Layout.titleLabelTopSpacing)

            make.leading
                .equalToSuperview()
                .offset(Layout.horizontalSpacing)

            // 버튼은 터치 영역만 넓힌 상태라, 눈에 보이는 아이콘 위치를 기준으로 잡습니다.
            make.trailing
                .equalToSuperview()
                .offset(-(Layout.horizontalSpacing + Layout.bookmarkIconSize + Layout.titleLabelTrailingSpacing))
        }

        periodLabel.snp.makeConstraints { make in
            make.top
                .equalTo(titleLabel.snp.bottom)
                .offset(Layout.periodLabelTopSpacing)

            make.leading
                .equalToSuperview()
                .offset(Layout.horizontalSpacing)

            make.trailing.equalTo(titleLabel.snp.trailing)

            make.bottom
                .equalToSuperview()
                .offset(-Layout.verticalSpacing)
        }
    }

    func configure(with item: YouthPolicyItem, onBookmarkTap: @escaping () -> Void) {
        badgeView.configure(with: item.badge)

        titleLabel.text = item.title

        periodLabel.text = item.periodText
        periodLabel.isHidden = item.periodText.isEmpty

        bookmarkButton.setImage(
            item.isBookmarked ? BitnagilIcon.heartFilledIcon : BitnagilIcon.heartEmptyIcon,
            for: .normal)

        self.onBookmarkTap = onBookmarkTap
    }
}
