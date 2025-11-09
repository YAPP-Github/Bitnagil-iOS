//
//  LocationButton.swift
//  Presentation
//
//  Created by 이동현 on 11/8/25.
//

import SnapKit
import UIKit

final class LocationButton: UIButton {
    private enum Layout {
        static let locationImageSize: CGFloat = 24
    }

    private let locationImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureAttribute()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAttribute() {
        backgroundColor = BitnagilColor.orange500
        locationImageView.image = BitnagilIcon.locationIcon
    }

    private func configureLayout() {
        addSubview(locationImageView)

        locationImageView.snp.makeConstraints { make in
            make.size.equalTo(Layout.locationImageSize)
            make.center.equalToSuperview()
        }
    }
}
