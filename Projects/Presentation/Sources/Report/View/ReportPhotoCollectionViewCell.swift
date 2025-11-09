//
//  ReportPhotoCollectionViewCell.swift
//  Presentation
//
//  Created by 이동현 on 11/8/25.
//

import SnapKit
import UIKit

protocol ReportPhotoCollectionViewCellDelegate: AnyObject {
    func reportPhotoCollectionViewCellWillDeleteCell(_ cell: ReportPhotoCollectionViewCell, uuid: UUID)
}

final class ReportPhotoCollectionViewCell: UICollectionViewCell {
    private enum Layout {
        static let imageCornerRadius: CGFloat = 8
        static let imageSize: CGFloat = 64
        static let deleteButtonSize: CGFloat = 16
    }

    private let imageView = UIImageView()
    private let deleteButton = UIButton()
    private let deleteButtonImageView = UIImageView()
    private var uuid: UUID?

    weak var delegate: ReportPhotoCollectionViewCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureAttribute()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

    private func configureAttribute() {
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = Layout.imageCornerRadius
        imageView.layer.masksToBounds = true

        deleteButton.addAction(
            UIAction { [weak self] _ in
                guard
                    let self,
                    let uuid
                else { return }

                self.delegate?.reportPhotoCollectionViewCellWillDeleteCell(self, uuid: uuid)
            },
            for: .touchUpInside)
        deleteButton.backgroundColor = .clear
        deleteButtonImageView.image = BitnagilIcon.roundDeleteIcon
    }

    private func configureLayout() {
        addSubview(imageView)
        addSubview(deleteButtonImageView)
        addSubview(deleteButton)

        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
            make.size.equalTo(Layout.imageSize)
        }

        deleteButton.snp.makeConstraints { make in
            make.size.equalTo(Layout.deleteButtonSize)
            make.centerY.equalTo(imageView.snp.top)
            make.centerX.equalTo(imageView.snp.trailing)
        }

        deleteButtonImageView.snp.makeConstraints { make in
            make.edges.equalTo(deleteButton)
        }
    }

    func configure(item: PhotoItem) {
        imageView.image = UIImage(data: item.data)
        uuid = item.id
    }
}
