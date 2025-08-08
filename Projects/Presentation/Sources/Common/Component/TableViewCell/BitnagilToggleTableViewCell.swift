//
//  BitnagilToggleTableViewCell.swift
//  Presentation
//
//  Created by 이동현 on 7/30/25.
//

import SnapKit
import UIKit

protocol BitnagilToggleTableViewCellDelegate: AnyObject {
    func bitnagilToggleTableViewCellDidToggle(_ sender: BitnagilToggleTableViewCell, isOn: Bool)
}

final class BitnagilToggleTableViewCell: BitnagilBaseTableViewCell {
    private enum Layout {
        static let switchTrailingSpacing: CGFloat = 20
        static let switchHeight: CGFloat = 24
        static let switchWidth: CGFloat = 44
    }

    private let toggleSwitch = UISwitch()
    weak var delegate: BitnagilToggleTableViewCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configureAttribute() {
        super.configureAttribute()

        toggleSwitch.onTintColor = BitnagilColor.navy500
        toggleSwitch.tintColor = BitnagilColor.gray95
        toggleSwitch.addAction(UIAction { [weak self] action in
            guard let self = self else { return }
            self.delegate?.bitnagilToggleTableViewCellDidToggle(self, isOn: toggleSwitch.isOn)
        }, for: .valueChanged)
    }

    override func configureLayout() {
        super.configureLayout()

        contentView.addSubview(toggleSwitch)

        toggleSwitch.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(Layout.switchTrailingSpacing)
            make.height.equalTo(Layout.switchHeight)
            make.width.equalTo(Layout.switchWidth)
        }
    }

    func configureToggleState(isOn: Bool) {
        toggleSwitch.isOn = isOn
    }
}
