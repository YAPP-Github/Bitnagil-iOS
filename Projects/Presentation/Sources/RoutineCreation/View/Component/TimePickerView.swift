//
//  DatePickerViewController.swift
//  Presentation
//
//  Created by 이동현 on 7/27/25.
//

import SnapKit
import UIKit

protocol TimePickerViewDelegate: AnyObject {
    func timePickerView(_ sender: TimePickerView, didSelectTime time: Date)
}

final class TimePickerView: UIViewController {
    private enum Layout {
        static let datePickerHeight: CGFloat = 195
        static let horizontalSpacing: CGFloat = 20
        static let registerButtonHeight: CGFloat = 54
        static let registerButtonTopSpacing: CGFloat = 36
        static let registerButtonBottomSpacing: CGFloat = 14
    }

    private let datePicker = UIDatePicker()
    private let registerButton = UIButton()
    weak var delegate: TimePickerViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAttribute()
        configureLayout()
    }

    private func configureAttribute() {
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .time

        datePicker.backgroundColor = .white
        datePicker.tintColor = .black

        registerButton.layer.cornerRadius = 12
        registerButton.layer.masksToBounds = true
        registerButton.backgroundColor = BitnagilColor.gray10
        registerButton.titleLabel?.font = BitnagilFont.init(style: .body1, weight: .semiBold).font
        registerButton.setTitle("확인", for: .normal)
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                self.delegate?.timePickerView(self, didSelectTime: datePicker.date)
                dismiss(animated: true)
            },
            for: .touchUpInside)
    }

    private func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        view.addSubview(datePicker)
        view.addSubview(registerButton)

        datePicker.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(Layout.datePickerHeight).priority(.medium)
        }

        registerButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(Layout.horizontalSpacing)
            make.top.equalTo(datePicker.snp.bottom).offset(Layout.registerButtonTopSpacing)
            make.bottom.equalTo(safeArea.snp.bottom).offset(-Layout.registerButtonBottomSpacing)
            make.height.equalTo(Layout.registerButtonHeight)
        }

    }
}
