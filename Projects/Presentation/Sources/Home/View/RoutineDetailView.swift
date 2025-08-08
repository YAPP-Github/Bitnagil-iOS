//
//  RoutineDetailView.swift
//  Presentation
//
//  Created by 최정인 on 7/30/25.
//

import SnapKit
import UIKit
import Shared

protocol RoutineDetailViewDelegate: AnyObject {
    func routineDetailView(_ sender: RoutineDetailView, didEditRoutine routine: MainRoutine)
    func routineDetailView(_ sender: RoutineDetailView, didDeleteRoutine routine: MainRoutine)
}

final class RoutineDetailView: UIViewController {

    private enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let contentStackViewSpacing: CGFloat = 24
        static let contentStackViewTopSpacing: CGFloat = 32
        static let routineIconSize: CGFloat = 28
        static let routineLabelHeight: CGFloat = 20
        static let routineLabelWidth: CGFloat = 60
        static let routineLabelLeadingSpacing: CGFloat = 9
        static let mainRoutineInfoStackViewSpacing: CGFloat = 9
        static let subRoutineStackViewSpacing: CGFloat = 0
        static let subRoutineInfoStackViewSpacing: CGFloat = 9
        static let subRoutineInfoStackViewHeight: CGFloat = 28
        static let subRoutineLabelHeight: CGFloat = 24
        static let repeatRoutineStackViewSpacing: CGFloat = 0
        static let repeatRoutineInfoStackViewSpacing: CGFloat = 9
        static let repeatRoutineTimeLabelHeight: CGFloat = 18
        static let buttonStackViewSpacing: CGFloat = 13
        static let buttonStackViewTopSpacing: CGFloat = 47
        static let buttonImagePadding: CGFloat = 8
        static let buttonCornerRadius: CGFloat = 12
        static let buttonHeight: CGFloat = 54
    }

    private let contentStackView = UIStackView()

    // 메인 루틴
    private let mainRoutineInfoStackView = UIStackView()
    private let mainRoutineIcon = UIImageView()
    private let mainRoutineLabel = UILabel()
    private let mainRoutineTitleLabel = UILabel()

    // 서브 루틴
    private let subRoutineStackView = UIStackView()
    private let subRoutineInfoStackView = UIStackView()
    private let subRoutineIcon = UIImageView()
    private let subRoutineLabel = UILabel()
    private let subRoutineTitleLabel = UILabel()

    // 루틴 반복
    private let repeatRoutineStackView = UIStackView()
    private let repeatRoutineInfoStackView = UIStackView()
    private let repeatRoutineIcon = UIImageView()
    private let repeatRoutineLabel = UILabel()
    private let repeatRoutineTitleLabel = UILabel()
    private let repeatRoutineTimeLabel = UILabel()

    // 버튼
    private let buttonStackView = UIStackView()
    private let editButton = UIButton()
    private let deleteButton = UIButton()

    weak var delegate: RoutineDetailViewDelegate?
    private let routine: MainRoutine
    init(routine: MainRoutine) {
        self.routine = routine
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAttribute()
        configureLayout()
    }

    private func configureAttribute() {
        // Content StackView
        contentStackView.axis = .vertical
        contentStackView.spacing = Layout.contentStackViewSpacing

        // 메인 루틴
        mainRoutineInfoStackView.axis = .horizontal
        mainRoutineInfoStackView.alignment = .center
        mainRoutineInfoStackView.spacing = Layout.mainRoutineInfoStackViewSpacing

        mainRoutineLabel.text = "루틴 이름"
        mainRoutineLabel.font = BitnagilFont(style: .body2, weight: .medium).font
        mainRoutineLabel.textColor = BitnagilColor.gray50

        mainRoutineIcon.image = BitnagilIcon.routineIcon
        mainRoutineIcon.contentMode = .scaleAspectFit

        mainRoutineTitleLabel.text = routine.title
        mainRoutineTitleLabel.font = BitnagilFont(style: .body2, weight: .semiBold).font
        mainRoutineTitleLabel.textColor = BitnagilColor.gray10
        mainRoutineTitleLabel.textAlignment = .right

        // 서브 루틴
        subRoutineStackView.axis = .vertical
        subRoutineStackView.spacing = Layout.subRoutineStackViewSpacing

        subRoutineInfoStackView.axis = .horizontal
        subRoutineInfoStackView.alignment = .center
        subRoutineInfoStackView.spacing = Layout.subRoutineInfoStackViewSpacing

        subRoutineLabel.text = "세부 루틴"
        subRoutineLabel.font = BitnagilFont(style: .body2, weight: .medium).font
        subRoutineLabel.textColor = BitnagilColor.gray50

        subRoutineIcon.image = BitnagilIcon.subRoutineIcon
        subRoutineIcon.contentMode = .scaleAspectFit

        subRoutineTitleLabel.text = "세부 루틴 없음"
        subRoutineTitleLabel.font = BitnagilFont(style: .body2, weight: .semiBold).font
        subRoutineTitleLabel.textColor = BitnagilColor.gray10
        subRoutineTitleLabel.textAlignment = .right


        // 루틴 반복
        repeatRoutineStackView.axis = .vertical
        repeatRoutineStackView.spacing = Layout.repeatRoutineStackViewSpacing

        repeatRoutineInfoStackView.axis = .horizontal
        repeatRoutineInfoStackView.alignment = .center
        repeatRoutineInfoStackView.spacing = Layout.repeatRoutineInfoStackViewSpacing

        repeatRoutineLabel.text = "루틴 반복"
        repeatRoutineLabel.font = BitnagilFont(style: .body2, weight: .medium).font
        repeatRoutineLabel.textColor = BitnagilColor.gray50

        repeatRoutineIcon.image = BitnagilIcon.repeatIcon
        repeatRoutineIcon.contentMode = .scaleAspectFit

        repeatRoutineTitleLabel.text = "반복 안함"
        repeatRoutineTitleLabel.font = BitnagilFont(style: .body2, weight: .semiBold).font
        repeatRoutineTitleLabel.textColor = BitnagilColor.gray10
        repeatRoutineTitleLabel.textAlignment = .right

        repeatRoutineTimeLabel.text = "\(routine.startTime.convertToString(dateType: .amPmTimeShort)) 시작"
        repeatRoutineTimeLabel.font = BitnagilFont(style: .caption1, weight: .medium).font
        repeatRoutineTimeLabel.textColor = BitnagilColor.gray40
        repeatRoutineTimeLabel.textAlignment = .right

        // 버튼
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = Layout.buttonStackViewSpacing
        buttonStackView.distribution = .fillEqually

        var editButtonConfiguration = UIButton.Configuration.filled()
        editButtonConfiguration.attributedTitle = AttributedString("수정하기", attributes: .init([.font: BitnagilFont(style: .subtitle1, weight: .semiBold).font]))
        editButtonConfiguration.image = BitnagilIcon.editIcon
        editButtonConfiguration.imagePlacement = .leading
        editButtonConfiguration.imagePadding = Layout.buttonImagePadding
        editButtonConfiguration.baseBackgroundColor = BitnagilColor.navy500
        editButtonConfiguration.baseForegroundColor = .white
        editButtonConfiguration.background.cornerRadius = Layout.buttonCornerRadius
        editButton.configuration = editButtonConfiguration
        editButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.delegate?.routineDetailView(self, didEditRoutine: routine)
        }, for: .touchUpInside)

        var deleteButtonConfiguration = UIButton.Configuration.filled()
        deleteButtonConfiguration.attributedTitle = AttributedString("삭제하기", attributes: .init([.font: BitnagilFont(style: .subtitle1, weight: .semiBold).font]))
        deleteButtonConfiguration.baseBackgroundColor = .white
        deleteButtonConfiguration.baseForegroundColor = BitnagilColor.navy500
        deleteButtonConfiguration.image = BitnagilIcon.trashIcon
        deleteButtonConfiguration.imagePlacement = .leading
        deleteButtonConfiguration.imagePadding = Layout.buttonImagePadding

        deleteButtonConfiguration.background.strokeColor = BitnagilColor.navy500
        deleteButtonConfiguration.background.strokeWidth = 1
        deleteButtonConfiguration.background.cornerRadius = Layout.buttonCornerRadius
        deleteButton.configuration = deleteButtonConfiguration
        deleteButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.delegate?.routineDetailView(self, didDeleteRoutine: routine)
        }, for: .touchUpInside)
    }

    private func configureLayout() {
        view.addSubview(contentStackView)
        view.addSubview(buttonStackView)

        // Content StackView
        [mainRoutineInfoStackView, subRoutineStackView, repeatRoutineStackView].forEach {
            contentStackView.addArrangedSubview($0)
        }

        // 메인 루틴
        [mainRoutineIcon, mainRoutineLabel, mainRoutineTitleLabel].forEach {
            mainRoutineInfoStackView.addArrangedSubview($0)
        }

        // 서브 루틴
        subRoutineStackView.addArrangedSubview(subRoutineInfoStackView)
        [subRoutineIcon, subRoutineLabel, subRoutineTitleLabel].forEach {
            subRoutineInfoStackView.addArrangedSubview($0)
        }

        // 반복 루틴
        repeatRoutineStackView.addArrangedSubview(repeatRoutineInfoStackView)
        repeatRoutineStackView.addArrangedSubview(repeatRoutineTimeLabel)
        [repeatRoutineIcon, repeatRoutineLabel, repeatRoutineTitleLabel].forEach {
            repeatRoutineInfoStackView.addArrangedSubview($0)
        }

        // 버튼
        [editButton, deleteButton].forEach {
            buttonStackView.addArrangedSubview($0)
        }

        contentStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Layout.contentStackViewTopSpacing)
            make.leading.equalToSuperview().offset(Layout.horizontalMargin)
            make.trailing.equalToSuperview().inset(Layout.horizontalMargin)
        }

        // 메인 루틴
        mainRoutineIcon.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.size.equalTo(Layout.routineIconSize)
        }

        mainRoutineLabel.snp.makeConstraints { make in
            make.leading.equalTo(mainRoutineIcon.snp.trailing).offset(Layout.routineLabelLeadingSpacing)
            make.height.equalTo(Layout.routineLabelHeight)
            make.width.equalTo(Layout.routineLabelWidth)
        }

        mainRoutineTitleLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.height.equalTo(Layout.routineLabelHeight)
            make.centerY.equalToSuperview()
        }

        // 서브 루틴
        subRoutineInfoStackView.snp.makeConstraints { make in
            make.height.equalTo(Layout.subRoutineInfoStackViewHeight)
        }

        subRoutineIcon.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(Layout.routineIconSize)
        }

        subRoutineLabel.snp.makeConstraints { make in
            make.leading.equalTo(subRoutineIcon.snp.trailing).offset(Layout.routineLabelLeadingSpacing)
            make.height.equalTo(Layout.routineLabelHeight)
            make.centerY.equalToSuperview()
            make.width.equalTo(Layout.routineLabelWidth)
        }

        subRoutineTitleLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.height.equalTo(Layout.routineLabelHeight)
            make.centerY.equalToSuperview()
        }

        // 반복 루틴
        repeatRoutineIcon.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.size.equalTo(Layout.routineIconSize)
        }

        repeatRoutineLabel.snp.makeConstraints { make in
            make.leading.equalTo(repeatRoutineIcon.snp.trailing).offset(Layout.routineLabelLeadingSpacing)
            make.height.equalTo(Layout.routineLabelHeight)
            make.width.equalTo(Layout.routineLabelWidth)
        }

        repeatRoutineTitleLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        repeatRoutineTimeLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(Layout.repeatRoutineTimeLabelHeight)
        }

        // 버튼 (수정 · 삭제)
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(contentStackView.snp.bottom).offset(Layout.buttonStackViewTopSpacing)
            make.leading.equalToSuperview().offset(Layout.horizontalMargin)
            make.trailing.equalToSuperview().inset(Layout.horizontalMargin)
            make.height.equalTo(Layout.buttonHeight)
        }

        editButton.snp.makeConstraints { make in
            make.size.equalTo(Layout.buttonHeight)
        }
        deleteButton.snp.makeConstraints { make in
            make.size.equalTo(Layout.buttonHeight)
        }

        if !routine.subRoutines.isEmpty {
            updateSubRoutineView()
        }

        if !routine.repeatDay.isEmpty {
            updateRepeatRoutine()
        }
    }

    private func updateSubRoutineView() {
        for i in 0..<routine.subRoutines.count {
            if i == 0 {
                subRoutineTitleLabel.text = routine.subRoutines[i].title
            } else {
                let addedSubRoutineLabel = UILabel()
                addedSubRoutineLabel.text = routine.subRoutines[i].title
                addedSubRoutineLabel.font = BitnagilFont(style: .body2, weight: .semiBold).font
                addedSubRoutineLabel.textColor = BitnagilColor.gray10
                addedSubRoutineLabel.textAlignment = .right
                subRoutineStackView.addArrangedSubview(addedSubRoutineLabel)
                addedSubRoutineLabel.snp.makeConstraints { make in
                    make.horizontalEdges.equalToSuperview()
                    make.height.equalTo(Layout.subRoutineLabelHeight)
                }
            }
        }
    }

    private func updateRepeatRoutine() {
        repeatRoutineTitleLabel.text = "\(routine.repeatDay.map({ $0.koreanValue }).joined(separator: ", "))"
    }
}
