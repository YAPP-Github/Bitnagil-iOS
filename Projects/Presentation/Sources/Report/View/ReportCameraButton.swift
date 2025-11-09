//
//  ReportCameraButton.swift
//  Presentation
//
//  Created by 이동현 on 11/8/25.
//

import SnapKit
import UIKit

final class ReportCameraButton: UIButton {
    private enum Layout {
        static let imageSize: CGFloat = 20
        static let imageTopSpacing: CGFloat = 15
    }

    private let cameraImageView = UIImageView()
    private let imageCountLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        backgroundColor = BitnagilColor.gray99
        cameraImageView.image = BitnagilIcon.cameraIcon
        configure(imageCount: 0, maxCount: 3)
    }

    private func configureLayout() {
        addSubview(cameraImageView)
        addSubview(imageCountLabel)

        cameraImageView.snp.makeConstraints { make in
            make.size.equalTo(Layout.imageSize)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Layout.imageTopSpacing)
        }

        imageCountLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(cameraImageView.snp.bottom)
        }
    }

    func configure(imageCount: Int, maxCount: Int) {
        let text = "\(imageCount)/\(maxCount)"

        let nsString = text as NSString
        let firstRange = nsString.rangeOfComposedCharacterSequence(at: .zero)

        let font = BitnagilFont.init(
            style: .button1,
            weight: .regular).font

        let attribute = NSMutableAttributedString(
            string: text,
            attributes: [
                .foregroundColor: BitnagilColor.gray70 ?? .black,
                .font: font])
        attribute
            .addAttributes(
                [.foregroundColor: BitnagilColor.gray10 ?? .black],
                range: firstRange)
        imageCountLabel.attributedText = attribute
    }
}
