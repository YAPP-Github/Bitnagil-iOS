//
//  DatePickerViewController.swift
//  Presentation
//
//  Created by 이동현 on 7/27/25.
//

import SnapKit
import UIKit

protocol DatePickerViewDelegate: AnyObject {
    func datePickerView(_ pickerView: DatePickerView, didSelectTime time: Date)
}

final class DatePickerView: UIViewController {
    private enum Layout {
        static let datePickerHeight: CGFloat = 195
        static let horizontalSpacing: CGFloat = 20
        static let registerButtonHeight: CGFloat = 54
        static let registerButtonVerticalSpacing: CGFloat = 14
    }

    private let datePicker = UIDatePicker()
    private let registerButton = UIButton()
    weak var delegate: DatePickerViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAttribute()
        configureLayout()
    }

    private func configureAttribute() {
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .time
        datePicker.locale = Locale(identifier: "en_US")
        datePicker.backgroundColor = .white
        datePicker.tintColor = .black

        registerButton.layer.cornerRadius = 12
        registerButton.layer.masksToBounds = true
        registerButton.backgroundColor = BitnagilColor.navy500
        registerButton.titleLabel?.font = BitnagilFont.init(style: .body1, weight: .semiBold).font
        registerButton.setTitle("등록하기", for: .normal)
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                self.delegate?.datePickerView(self, didSelectTime: datePicker.date)
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
            make.height.equalTo(Layout.datePickerHeight)
        }

        registerButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(Layout.horizontalSpacing)
            make.top.equalTo(datePicker.snp.bottom).offset(Layout.registerButtonVerticalSpacing)
            make.bottom.equalTo(safeArea.snp.bottom).offset(-Layout.registerButtonVerticalSpacing)
            make.height.equalTo(Layout.registerButtonHeight)
        }
    }
}
