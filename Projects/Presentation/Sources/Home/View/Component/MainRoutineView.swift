//
//  MainRoutineView.swift
//  Presentation
//
//  Created by 최정인 on 7/18/25.
//

import UIKit

protocol MainRoutineViewDelegate: AnyObject {
    func mainRoutineView(_ sender: MainRoutineView, didTapCheckButton mainRoutine: MainRoutine)
    func mainRoutineView(_ sender: MainRoutineView, didTapMoreButton mainRoutine: MainRoutine)
}

final class MainRoutineView: UIView {

    private let mainLabel = UILabel()
    private let checkButton = UIButton()
    private let checkBackgroundView = UIView()
    private let checkIcon = UIImageView()
    private let moreButton = UIButton()

    private var mainRoutine: MainRoutine {
        didSet {
            updateAttribute()
        }
    }
    weak var delegate: MainRoutineViewDelegate?

    init(mainRoutine: MainRoutine) {
        self.mainRoutine = mainRoutine
        super.init(frame: .zero)
        configureAttribute()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureAttribute() {
        backgroundColor = BitnagilColor.lightBlue75
        layer.masksToBounds = true
        layer.cornerRadius = 8

        mainLabel.do {
            $0.text = mainRoutine.title
            $0.font = BitnagilFont(style: .subtitle1, weight: .semiBold).font
            $0.textColor = BitnagilColor.navy500
        }

        checkButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.delegate?.mainRoutineView(self, didTapCheckButton: mainRoutine)
        }, for: .touchUpInside)

        checkBackgroundView.do {
            $0.isUserInteractionEnabled = false
            $0.backgroundColor = .white
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 5.33
        }

        checkIcon.do {
            $0.image = BitnagilIcon.checkIcon
            $0.tintColor = BitnagilColor.navy50
        }

        moreButton.do {
            $0.setImage(BitnagilIcon.ellipsisIcon, for: .normal)
            $0.addAction(UIAction { [weak self] _ in
                guard let self else { return }
                self.delegate?.mainRoutineView(self, didTapMoreButton: mainRoutine)
            }, for: .touchUpInside)
        }
    }

    private func configureLayout() {
        [checkBackgroundView, checkIcon].forEach {
            checkButton.addSubview($0)
        }
        addSubview(checkButton)
        addSubview(mainLabel)
        addSubview(moreButton)

        checkBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        checkIcon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(24)
        }

        checkButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.size.equalTo(24)
        }

        mainLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(checkButton.snp.trailing).offset(12)
        }

        moreButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(5)
            make.size.equalTo(24)
        }
    }

    private func updateAttribute() {
        let isDone = mainRoutine.isDone
        checkIcon.tintColor = isDone ? BitnagilColor.navy500 : BitnagilColor.navy50
    }

    func updateState(isDone: Bool) {
        mainRoutine.isDone = isDone
    }
}

struct MainRoutine {
    let title: String
    var isDone: Bool
}
