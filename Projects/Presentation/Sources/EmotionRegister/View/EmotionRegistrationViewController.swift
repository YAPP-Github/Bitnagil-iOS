//
//  EmotionRegistrationViewController.swift
//  Presentation
//
//  Created by 이동현 on 8/19/25.
//

import Combine
import SnapKit
import UIKit

final class EmotionRegistrationViewController: BaseViewController<EmotionRegisterViewModel> {
    private enum Layout {
        static let smallMarbleScrollViewHeight: CGFloat = 40
        static let smallMarbleScrollViewTopSpacing: CGFloat = 70
        static let marbleStackViewHorizontalSpacing: CGFloat = 20
        static let marbleStackViewContentSpacing: CGFloat = 19
        static let smallMarbleImageSize: CGFloat = 40
        static let emotionLabelWidth: CGFloat = 92
        static let emotionLabelHeight: CGFloat = 36
        static let emotionCollectionViewHeight: CGFloat = 191
        static let emotionMarbleImageViewSize: CGFloat = 140
        static let emotionMarbleImageViewTopSpacing: CGFloat = 13
        static let speechImageTopSpacing: CGFloat = 26
        static let speechImageHorizontalSpacing: CGFloat = 54
        static let speechImageHeight: CGFloat = 102
        static let speechLabelTopSpacing: CGFloat = 22
        static let fomoHandImageWidth: CGFloat = 263
        static let fomoHandImageHeight: CGFloat = 207
        static let fomoThumbImageWidth: CGFloat = 80
        static let fomoThumbImageHeight: CGFloat = 65
        static let foromThumbTopSpacing: CGFloat = 64
        static let foromThumbLeadingSpacing: CGFloat = 71
        static let handMarbleImageViewBottomSpacing: CGFloat = 7
        static let handMarbleImageViewTopSpacing: CGFloat = 50
        static let infoLabelTopSpacing: CGFloat = 30
        static let doubleChevronIconSize: CGFloat = 24
        static let doubleChevronIconHorizontalSpacing: CGFloat = 26
        static let doubleChevronIconTopSpacing: CGFloat = 10
        static let infoViewSize: CGFloat = 0
    }

    private let smallMarbleScrollView = UIScrollView()
    private let smallMarbleStackView = UIStackView()
    private let emotionLabel = UILabel()
    private let emotionCollectionView = UICollectionView(frame: .zero, collectionViewLayout: EmotionCollectionViewLayout())
    private let emotionMarbleImageView = UIImageView()
    private let handMarbleView = UIView()
    private let speechImageView = UIImageView()
    private let speechLabel = UILabel()
    private let handImageView = UIImageView()
    private let thumbImageView = UIImageView()
    private let infoView = UIView()
    private let infoLabel = UILabel()
    private let leftDoubleChevronImageView = UIImageView()
    private let rightDoubleChevronImageView = UIImageView()
    private let downDoubleChevronImageView = UIImageView()
    private var isMarbleHeld = false
    private var marbleImageViewMidY: CGFloat?
    private var marbleImageViewPanGesture: UIPanGestureRecognizer?
    private var emotion: Emotion?
    private var dataSource: UICollectionViewDiffableDataSource<Int, Emotion>?
    private var cancellables: Set<AnyCancellable>
    var itemCount: Int {
        return (dataSource?.snapshot().numberOfItems ?? 0) / 3
    }


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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if view.frame.maxY == view.safeAreaLayoutGuide.layoutFrame.maxY {
            handMarbleView.snp.remakeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(infoLabel.snp.bottom).offset(Layout.handMarbleImageViewTopSpacing)
                make.size.equalTo(Layout.emotionMarbleImageViewSize)
            }

            handImageView.isHidden = true
            thumbImageView.isHidden = true
        }

        if marbleImageViewMidY == nil { marbleImageViewMidY = emotionMarbleImageView.center.y }
    }

    override func configureAttribute() {
        view.backgroundColor = .white

        configureMarbleImageView()
        configureSmallMarbleViews()
        configureCustomNavigationBar(navigationBarStyle: .withBackButton(title: "오늘 감정 등록하기"))

        emotionCollectionView.register(EmotionCollectionViewCell.self, forCellWithReuseIdentifier: EmotionCollectionViewCell.className)
        emotionCollectionView.delegate = self
        emotionCollectionView.showsHorizontalScrollIndicator = false
        emotionCollectionView.decelerationRate = .fast

        emotionLabel.layer.cornerRadius = 10
        emotionLabel.layer.masksToBounds = true
        emotionLabel.font = BitnagilFont(style: .title3, weight: .semiBold).font
        emotionLabel.textAlignment = .center

        speechImageView.image = BitnagilGraphic.marbleSpeechGraphic?.withRenderingMode(.alwaysTemplate)
        speechImageView.tintColor = .clear
        speechLabel.numberOfLines = 2
        speechLabel.textAlignment = .center
        speechLabel.font = BitnagilFont.init(style:.cafe24Title2, weight: .light).font
        speechLabel.textColor = .clear

        infoLabel.numberOfLines = 0
        infoLabel.font = BitnagilFont.init(style: .body2, weight: .medium).font
        infoLabel.textColor = BitnagilColor.gray50
        infoLabel.textAlignment = .center

        leftDoubleChevronImageView.image = BitnagilIcon.doubleChevronIcon(direction: .left)
        rightDoubleChevronImageView.image = BitnagilIcon.doubleChevronIcon(direction: .right)
        downDoubleChevronImageView.image = BitnagilIcon.doubleChevronIcon(direction: .down)

        handImageView.image = BitnagilGraphic.fomoHandGraphic
        thumbImageView.image = BitnagilGraphic.fomoThumbGraphic

        [
            leftDoubleChevronImageView,
            rightDoubleChevronImageView,
            downDoubleChevronImageView].forEach {
                $0.tintColor = BitnagilColor.gray60
            }

        dataSource = UICollectionViewDiffableDataSource<Int, Emotion>(collectionView: emotionCollectionView) { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmotionCollectionViewCell.className, for: indexPath) as? EmotionCollectionViewCell else { return UICollectionViewCell() }
            cell.configure(image: item.image)
            return cell
        }
    }

    override func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide

        view.addSubview(smallMarbleScrollView)
        view.addSubview(emotionCollectionView)
        view.addSubview(emotionLabel)
        view.addSubview(speechImageView)
        view.addSubview(speechLabel)
        view.addSubview(handImageView)
        view.addSubview(emotionMarbleImageView)
        view.addSubview(handMarbleView)
        view.addSubview(thumbImageView)
        view.addSubview(infoView)
        smallMarbleScrollView.addSubview(smallMarbleStackView)
        infoView.addSubview(infoLabel)
        infoView.addSubview(leftDoubleChevronImageView)
        infoView.addSubview(rightDoubleChevronImageView)
        infoView.addSubview(downDoubleChevronImageView)

        smallMarbleScrollView.snp.makeConstraints { make in
            make.height.equalTo(Layout.smallMarbleScrollViewHeight)
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(safeArea.snp.top).offset(Layout.smallMarbleScrollViewTopSpacing)
        }

        smallMarbleStackView.snp.makeConstraints { make in
            make.verticalEdges.equalTo(smallMarbleScrollView.contentLayoutGuide)
            make.horizontalEdges.equalTo(smallMarbleScrollView.contentLayoutGuide).inset(Layout.marbleStackViewHorizontalSpacing)
            make.height.equalTo(smallMarbleScrollView.snp.height)
            make.width.equalTo(smallMarbleScrollView.frameLayoutGuide).priority(.low)
        }

        speechImageView.snp.makeConstraints { make in
            make.top.equalTo(smallMarbleStackView.snp.bottom).offset(Layout.speechImageTopSpacing)
            make.horizontalEdges.equalToSuperview().inset(Layout.speechImageHorizontalSpacing)
            make.height.equalTo(Layout.speechImageHeight)
        }

        speechLabel.snp.makeConstraints { make in
            make.top.equalTo(speechImageView.snp.top).offset(Layout.speechLabelTopSpacing)
            make.centerX.equalTo(speechImageView)
        }

        emotionCollectionView.snp.makeConstraints {
            $0.top.equalTo(speechImageView.snp.bottom).offset(17)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Layout.emotionCollectionViewHeight)
        }

        emotionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(emotionCollectionView)
            make.height.equalTo(Layout.emotionLabelHeight)
            make.width.equalTo(Layout.emotionLabelWidth)
        }

        emotionMarbleImageView.snp.makeConstraints { make in
            make.top.equalTo(emotionLabel.snp.bottom).offset(Layout.emotionMarbleImageViewTopSpacing)
            make.centerX.equalToSuperview()
            make.size.equalTo(Layout.emotionMarbleImageViewSize)
        }

        infoView.snp.makeConstraints { make in
            make.top.equalTo(emotionCollectionView.snp.bottom).offset(Layout.infoLabelTopSpacing)
            make.centerX.equalToSuperview()
            make.width.equalTo(Layout.infoViewSize).priority(.low)
            make.height.equalTo(Layout.infoViewSize).priority(.low)
        }

        infoLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        leftDoubleChevronImageView.snp.makeConstraints { make in
            make.centerY.equalTo(infoLabel)
            make.trailing.equalTo(infoLabel.snp.leading).offset(-Layout.doubleChevronIconHorizontalSpacing)
            make.size.equalTo(Layout.doubleChevronIconSize)
        }

        rightDoubleChevronImageView.snp.makeConstraints { make in
            make.centerY.equalTo(infoLabel)
            make.leading.equalTo(infoLabel.snp.trailing).offset(Layout.doubleChevronIconHorizontalSpacing)
            make.size.equalTo(Layout.doubleChevronIconSize)
        }

        downDoubleChevronImageView.snp.makeConstraints { make in
            make.centerX.equalTo(infoLabel)
            make.top.equalTo(infoLabel.snp.bottom).offset(Layout.doubleChevronIconTopSpacing)
            make.size.equalTo(Layout.doubleChevronIconSize)
        }

        handImageView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(Layout.fomoHandImageHeight)
            make.width.equalTo(Layout.fomoHandImageWidth)
        }

        thumbImageView.snp.makeConstraints { make in
            make.top.equalTo(handImageView.snp.top).offset(Layout.foromThumbTopSpacing)
            make.leading.equalTo(handImageView.snp.leading).offset(Layout.foromThumbLeadingSpacing)
            make.height.equalTo(Layout.fomoThumbImageHeight)
            make.width.equalTo(Layout.fomoThumbImageWidth)
        }

        handMarbleView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(thumbImageView.snp.bottom).offset(-Layout.handMarbleImageViewBottomSpacing)
            make.size.equalTo(Layout.emotionMarbleImageViewSize)
        }
    }

    override func bind() {
        viewModel.output.emotionListPublisher
            .receive(on: DispatchQueue.main)
            .sink {[weak self] emotions in
                guard let self = self else { return }

                let originalEmotionCount = emotions.count
                let tripledEmotions = emotions.map({ $0.copy() }) + emotions + emotions.map({ $0.copy() })

                var snapshot = NSDiffableDataSourceSnapshot<Int, Emotion>()
                snapshot.appendSections([0])
                snapshot.appendItems(tripledEmotions)
                self.dataSource?.apply(snapshot, animatingDifferences: false)

                self.scrollToIndex(index: originalEmotionCount)
                viewModel.action(input: .selectEmotion(index: 0))
            }
            .store(in: &cancellables)

        viewModel.output.selectedEmotionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] emotion in
                guard
                    let self = self,
                    let emotion
                else { return }

                self.emotion = emotion
                UIView.animate(
                    withDuration: 0.4,
                    delay: 0,
                    options: [.curveEaseInOut]
                ) {
                    self.emotionMarbleImageView.image = emotion.image
                    self.emotionLabel.backgroundColor = emotion.backgroundColor
                    self.speechImageView.tintColor = emotion.backgroundColor
                    self.speechLabel.textColor = emotion.textColor
                    self.emotionLabel.textColor = emotion.textColor
                    self.speechLabel.text = emotion.emotionMessage
                    self.emotionLabel.text = emotion.emotionTitle
                    self.emotionMarbleImageView.isHidden = false
                }
            }
            .store(in: &cancellables)

        viewModel.output.confirmEmotionEnabledPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] canConfirmEmotion in
                self?.emotionMarbleImageView.isUserInteractionEnabled = canConfirmEmotion
                self?.rightDoubleChevronImageView.isHidden = canConfirmEmotion
                self?.leftDoubleChevronImageView.isHidden = canConfirmEmotion
                self?.downDoubleChevronImageView.isHidden = !canConfirmEmotion

                let infoMessage = canConfirmEmotion
                                ? """
                                  선택한 감정 구슬을 아래로 놓아주세요
                                  """
                                : """
                                  좌우로 스와이프해
                                  감정 구슬을 골라주세요
                                  """
                self?.infoLabel.text = infoMessage
            }
            .store(in: &cancellables)
    }

    private func configureSmallMarbleViews() {
        smallMarbleScrollView.showsHorizontalScrollIndicator = false

        smallMarbleStackView.axis = .horizontal
        smallMarbleStackView.distribution = .equalSpacing
        smallMarbleStackView.spacing = Layout.marbleStackViewContentSpacing

        Marble.allCases.dropFirst().forEach {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapSmallMarbleImage(gesture:)))
            let smallMarbleImageView = UIImageView()

            smallMarbleImageView.image = $0.marbleImage
            smallMarbleImageView.addGestureRecognizer(tapGesture)
            smallMarbleImageView.isUserInteractionEnabled = true

            smallMarbleImageView.snp.makeConstraints { make in
                make.size.equalTo(Layout.smallMarbleImageSize)
            }
            
            smallMarbleStackView.addArrangedSubview(smallMarbleImageView)
        }
    }

    private func configureMarbleImageView() {
        marbleImageViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        marbleImageViewPanGesture?.cancelsTouchesInView = false

        handMarbleView.layer.cornerRadius = Layout.emotionMarbleImageViewSize / 2
        handMarbleView.layer.masksToBounds = true
        handMarbleView.backgroundColor = .clear

        emotionMarbleImageView.isUserInteractionEnabled = true
        emotionMarbleImageView.layer.cornerRadius = Layout.emotionMarbleImageViewSize / 2
        emotionMarbleImageView.layer.masksToBounds = true

        guard let marbleImageViewPanGesture else { return }

        emotionMarbleImageView.addGestureRecognizer(marbleImageViewPanGesture)
    }

    @objc private func handleTapSmallMarbleImage(gesture: UITapGestureRecognizer) {
        guard
            let tappedSmallMarbleView = gesture.view,
            let index = smallMarbleStackView.arrangedSubviews.firstIndex(of: tappedSmallMarbleView)
        else { return }

        scrollToIndex(index: index + 1, animated: true) { [weak self] in
            self?.viewModel.action(input: .selectEmotion(index: index + 1))
        }
    }

    @objc private func handlePan(gesture: UIPanGestureRecognizer) {
        guard let marbleImageViewMidY else { return }

        switch gesture.state {
        case .began:
            infoView.isHidden = true
        case .changed:
            let translationY = gesture.translation(in: view).y
            let offSet = max(0, translationY)

            guard offSet <= handMarbleView.frame.midY - marbleImageViewMidY else { return }

            emotionMarbleImageView.transform = CGAffineTransform(translationX: 0, y: offSet)
        case .ended, .cancelled, .failed:
            if emotionMarbleImageView.frame.maxY > handMarbleView.frame.minY + (Layout.emotionMarbleImageViewSize / 2) {
                let dy = handMarbleView.frame.midY - marbleImageViewMidY
                UIView.animate(
                    withDuration: 0.3,
                    delay: 0,
                    options: [.curveEaseInOut]
                ) {
                    self.emotionMarbleImageView.transform = CGAffineTransform(translationX: 0, y: dy)
                } completion: { _ in
                    guard let emotion = self.emotion else { return }
                    let completionViewController = EmotionRegisterCompletionViewController(emotion: emotion)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        self.navigationController?.pushViewController(completionViewController, animated: true)
                    }
                }
            } else {
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0,
                    options: [.curveEaseInOut]
                ) {
                    self.emotionMarbleImageView.transform = .identity
                    self.infoView.isHidden = false
                }
            }
        default:
            break
        }
    }

    private func scrollToIndex(
        index: Int,
        animated: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        guard itemCount > 0 else { return }

        let index = (index + itemCount) % itemCount
        let targetIndex = index + itemCount
        let indexPath = IndexPath(item: targetIndex, section: 0)

        emotionMarbleImageView.isHidden = true
        emotionCollectionView.scrollToItem(
            at: indexPath,
            at: .centeredHorizontally,
            animated: animated)

        if !animated {
            completion?()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                completion?()
            }
        }
    }
}

extension EmotionRegistrationViewController: UICollectionViewDelegate {

}

extension EmotionRegistrationViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        emotionMarbleImageView.isHidden = true
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let centerPoint = CGPoint(
            x: emotionCollectionView.contentOffset.x + emotionCollectionView.frame.midX,
            y: emotionCollectionView.contentOffset.y)

        guard
            let collectionView = scrollView as? UICollectionView,
            let indexPath = collectionView.indexPathForItem(at: centerPoint),
            itemCount > 0
        else { return }

        let index = indexPath.row % itemCount
        if indexPath.row < itemCount / 3 || indexPath.row >= itemCount * 2 / 3 {
            scrollToIndex(index: index)
        }
        viewModel.action(input: .selectEmotion(index: index))
    }
}

