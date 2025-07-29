//
//  EmotionRegisterView.swift
//  Presentation
//
//  Created by 최정인 on 7/28/25.
//

import Combine
import Shared
import SnapKit
import UIKit

final class EmotionRegisterView: BaseViewController<EmotionRegisterViewModel> {

    private enum Layout {
        static let mainLabelTopSpacing: CGFloat = 32
        static let mainLabelHeight: CGFloat = 30
        static let subLabelTopSpacing: CGFloat = 6
        static let subLabelHeight: CGFloat = 28
        static let emotionOrbCellWidth: CGFloat = 96
        static let emotionOrbCellHeight: CGFloat = 126
        static let emotionOrbCollectionViewItemSpacing: CGFloat = 13
        static let emotionOrbCollectionViewLineSpacing: CGFloat = 28
        static let emotionOrbCollectionViewTopSpacing: CGFloat = 56
        static let emotionOrbCollectionViewHorizontalMargin: CGFloat = 30
        static let emotionOrbCollectionViewHeight: CGFloat = 280
    }

    private let mainLabel = UILabel()
    private let subLabel = UILabel()
    private let emotionOrbCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: Layout.emotionOrbCellWidth, height: Layout.emotionOrbCellHeight)
        layout.minimumInteritemSpacing = Layout.emotionOrbCollectionViewItemSpacing
        layout.minimumLineSpacing = Layout.emotionOrbCollectionViewLineSpacing
        layout.sectionInset = .zero

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    private var emotionList: [Emotion] = []
    private var cancellables: Set<AnyCancellable>

    override init(viewModel: EmotionRegisterViewModel) {
        cancellables = []
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.action(input: .fetchEmotions)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(navigationStyle: .withBackButton(title: ""))
    }

    override func configureAttribute() {
        mainLabel.text = "오늘의 감정구슬을 골라보세요"
        mainLabel.textAlignment = .center
        mainLabel.font = BitnagilFont(style: .title2, weight: .bold).font
        mainLabel.textColor = BitnagilColor.navy500

        subLabel.text = "감정구슬을 등록하면 루틴을 추천받아요!"
        subLabel.textAlignment = .center
        subLabel.font = BitnagilFont(style: .subtitle1, weight: .regular).font
        subLabel.textColor = BitnagilColor.navy300

        emotionOrbCollectionView.backgroundColor = .clear

        emotionOrbCollectionView.delegate = self
        emotionOrbCollectionView.dataSource = self
        emotionOrbCollectionView.register(EmotionOrbCollectionViewCell.self, forCellWithReuseIdentifier: EmotionOrbCollectionViewCell.className)
    }

    override func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        view.backgroundColor = .systemBackground

        view.addSubview(mainLabel)
        view.addSubview(subLabel)
        view.addSubview(emotionOrbCollectionView)

        mainLabel.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(Layout.mainLabelTopSpacing)
            make.horizontalEdges.equalTo(safeArea)
            make.height.equalTo(Layout.mainLabelHeight)
        }

        subLabel.snp.makeConstraints { make in
            make.top.equalTo(mainLabel.snp.bottom).offset(Layout.subLabelTopSpacing)
            make.horizontalEdges.equalTo(safeArea)
            make.height.equalTo(Layout.subLabelHeight)
        }

        emotionOrbCollectionView.snp.makeConstraints { make in
            make.top.equalTo(subLabel.snp.bottom).offset(Layout.emotionOrbCollectionViewTopSpacing)
            make.leading.equalTo(safeArea).offset(Layout.emotionOrbCollectionViewHorizontalMargin)
            make.trailing.equalTo(safeArea).inset(Layout.emotionOrbCollectionViewHorizontalMargin)
            make.height.equalTo(Layout.emotionOrbCollectionViewHeight)
        }
    }

    override func bind() {
        viewModel.output.emotionListPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] emotionList in
                self?.emotionList = emotionList
                if !emotionList.isEmpty {
                    self?.emotionOrbCollectionView.reloadData()
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: UICollectionViewDelegate
extension EmotionRegisterView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedEmotion = emotionList[indexPath.item]
        guard let resultRecommendedRoutineViewModel = DIContainer.shared.resolve(type: ResultRecommendedRoutineViewModel.self)
        else { fatalError("resultRecommendedRoutineViewModel 의존성이 등록되지 않았습니다.") }
        resultRecommendedRoutineViewModel.configure(viewModelType: .emotion(emotion: selectedEmotion))

        let resultRecommendedRoutineView = ResultRecommendedRoutineView(entryPoint: .emotion, viewModel: resultRecommendedRoutineViewModel)
        self.navigationController?.pushViewController(resultRecommendedRoutineView, animated: true)
    }
}

// MARK: UICollectionViewDataSource
extension EmotionRegisterView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emotionList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmotionOrbCollectionViewCell.className, for: indexPath) as? EmotionOrbCollectionViewCell
        else { return UICollectionViewCell() }

        let emotion = emotionList[indexPath.item]
        cell.configureCell(emotion: emotion)
        return cell
    }
}
