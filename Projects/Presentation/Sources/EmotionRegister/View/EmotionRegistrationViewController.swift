//
//  EmotionRegistrationViewController.swift
//  Presentation
//
//  Created by 이동현 on 8/19/25.
//

import SnapKit
import UIKit

final class EmotionRegistrationViewController: BaseViewController<EmotionRegisterViewModel> {
    private enum Layout {
        static let marbleStackViewHeight: CGFloat = 40
        static let marbleStackViewTopSpacing: CGFloat = 20
        static let marbleStackViewHorizontalSpacing: CGFloat = 20
        static let smallMarbleImageSize: CGFloat = 40
        static let emotionLabelWidth: CGFloat = 92
        static let emotionLabelHeight: CGFloat = 36
        static let emotionCollectionViewHeight: CGFloat = 191
        static let emotionCollectionViewBottomSpacing: CGFloat = 113
        static let emotionMarbleImageViewSize: CGFloat = 140
        static let emotionMarbleImageViewTopSpacing: CGFloat = 13
        static let speechImageBottomSpacing: CGFloat = 21
        static let speechImageHorizontalSpacing: CGFloat = 54
        static let speechImageHeight: CGFloat = 102
        static let speechLabelTopSpacing: CGFloat = 22
        static let fomoHandImageWidth: CGFloat = 263
        static let fomoHandImageHeight: CGFloat = 207
        static let fomoThumbImageWidth: CGFloat = 80
        static let fomoThumbImageHeight: CGFloat = 65
        static let foromThumbTopSpacing: CGFloat = 64
        static let foromThumbLeadingSpacing: CGFloat = 71
        static let handMarbleImageViewLeadingSpacing: CGFloat = 9
        static let handMarbleImageViewBottomSpacing: CGFloat = 7
        static let infoLabelTopSpacing: CGFloat = 30
        static let infoLabelHeight: CGFloat = 40
        static let doubleChevronIconSize: CGFloat = 24
        static let doubleChevronIconHorizontalSpacing: CGFloat = 26
        static let doubleChevronIconTopSpacing: CGFloat = 10
        static let doubleChevronIconBottomSpacing: CGFloat = 29
    }

    private let marbleStackView = UIStackView()
    private let emotionLabel = UILabel()
    private let emotionCollectionView = UICollectionView(frame: .zero, collectionViewLayout: EmotionCollectionViewLayout())
    private let emotionMarbleImageView = UIImageView()
    private let handMarbleView = UIView()
    private let speechImageView = UIImageView()
    private let speechLabel = UILabel()
    private let handImageView = UIImageView()
    private let thumbImageView = UIImageView()
    private let infoLabel = UILabel()
    private let leftDoubleChevronImageView = UIImageView()
    private let rightDoubleChevronImageView = UIImageView()
    private let downDoubleChevronImageView = UIImageView()
    private var isMarbleHeld = false
    private var marbleImageViewMidY: CGFloat?
    private var marbleImageViewPanGesture: UIPanGestureRecognizer?
    private var emotion: Marble?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureAttribute()
        configureLayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if marbleImageViewMidY == nil { marbleImageViewMidY = emotionMarbleImageView.center.y }
    }

    override func configureAttribute() {
        configureMarbleImageView()
        configureCustomNavigationBar(navigationBarStyle: .withBackButton(title: "오늘 감정 등록하기"))

        emotionCollectionView.register(EmotionCollectionViewCell.self, forCellWithReuseIdentifier: EmotionCollectionViewCell.className)
        emotionCollectionView.delegate = self
        emotionCollectionView.dataSource = self
        emotionCollectionView.showsHorizontalScrollIndicator = false
        emotionCollectionView.decelerationRate = .fast

        emotionLabel.layer.cornerRadius = 10
        emotionLabel.layer.masksToBounds = true
        emotionLabel.font = BitnagilFont(style: .title3, weight: .semiBold).font
        emotionLabel.backgroundColor = Marble.NONE.backgroundColor
        emotionLabel.text = "구슬선택"
        emotionLabel.textAlignment = .center
        emotionLabel.textColor = Marble.NONE.textColor

        speechImageView.image = BitnagilGraphic.marbleSpeechGraphic?.withRenderingMode(.alwaysTemplate)
        speechImageView.tintColor = Marble.NONE.backgroundColor
        speechLabel.numberOfLines = 2
        speechLabel.textAlignment = .center
        speechLabel.font = BitnagilFont.init(style:.cafe24Title1, weight: .light).font
        speechLabel.text = "오늘 기분 어때요?\n기록해 두면 내 루틴에 도움 돼요!"
        speechLabel.textColor = Marble.NONE.textColor

        infoLabel.numberOfLines = 2
        infoLabel.font = BitnagilFont.init(style: .body2, weight: .medium).font
        infoLabel.textColor = BitnagilColor.gray50
        infoLabel.textAlignment = .center
        infoLabel.text = "좌우로 스와이프해\n감정 구슬을 골라주세요."

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
    }

    override func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide

        view.addSubview(marbleStackView)
        view.addSubview(emotionCollectionView)
        view.addSubview(emotionLabel)
        view.addSubview(speechImageView)
        view.addSubview(speechLabel)
        view.addSubview(handImageView)
        view.addSubview(emotionMarbleImageView)
        view.addSubview(handMarbleView)
        view.addSubview(thumbImageView)
        view.addSubview(infoLabel)
        view.addSubview(leftDoubleChevronImageView)
        view.addSubview(rightDoubleChevronImageView)
        view.addSubview(downDoubleChevronImageView)

        marbleStackView.snp.makeConstraints { make in
            make.height.equalTo(Layout.marbleStackViewHeight)
            make.horizontalEdges.equalToSuperview().inset(Layout.marbleStackViewHorizontalSpacing)
            make.top.equalTo(safeArea.snp.top).offset(Layout.marbleStackViewTopSpacing)
        }

        emotionCollectionView.snp.makeConstraints {
            $0.bottom.equalTo(handImageView.snp.top).offset(-Layout.emotionCollectionViewBottomSpacing)
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

        speechImageView.snp.makeConstraints { make in
            make.bottom.equalTo(emotionLabel.snp.top).offset(-Layout.speechImageBottomSpacing)
            make.horizontalEdges.equalToSuperview().inset(Layout.speechImageHorizontalSpacing)
            make.height.equalTo(Layout.speechImageHeight)
        }

        speechLabel.snp.makeConstraints { make in
            make.top.equalTo(speechImageView.snp.top).offset(Layout.speechLabelTopSpacing)
            make.centerX.equalTo(speechImageView)
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
            make.leading.equalTo(thumbImageView.snp.leading).offset(-Layout.handMarbleImageViewLeadingSpacing)
            make.bottom.equalTo(thumbImageView.snp.bottom).offset(-Layout.handMarbleImageViewBottomSpacing)
            make.size.equalTo(Layout.emotionMarbleImageViewSize)
        }

        infoLabel.snp.makeConstraints { make in
            make.top.equalTo(emotionCollectionView.snp.bottom).offset(Layout.infoLabelTopSpacing)
            make.centerX.equalToSuperview()
            make.height.equalTo(Layout.infoLabelHeight)
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
            make.bottom.equalTo(handImageView.snp.top).offset(-Layout.doubleChevronIconBottomSpacing)
        }
    }

    private func configureMarbleStackView() {
        marbleStackView.axis = .horizontal
        marbleStackView.distribution = .equalSpacing
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

    @objc private func handlePan(gesture: UIPanGestureRecognizer) {

        guard let marbleImageViewMidY else { return }

        switch gesture.state {
        case .began:
            [
                leftDoubleChevronImageView,
                rightDoubleChevronImageView,
                downDoubleChevronImageView,
                infoLabel].forEach {
                    $0.isHidden = true
                }

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
                ) { self.emotionMarbleImageView.transform = .identity }
            }

            [
                leftDoubleChevronImageView,
                rightDoubleChevronImageView,
                downDoubleChevronImageView,
                infoLabel].forEach {
                    $0.isHidden = false
                }
        default:
            break
        }
    }
}

extension EmotionRegistrationViewController: UICollectionViewDelegate {

}

extension EmotionRegistrationViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Marble.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmotionCollectionViewCell.className, for: indexPath) as? EmotionCollectionViewCell else { return .init() }

        let marble = Marble.allCases[indexPath.row]
        cell.configure(image: marble.marbleImage)
        return cell
    }
}

extension EmotionRegistrationViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        emotionMarbleImageView.isHidden = true
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        emotionMarbleImageView.isHidden = false
        print(emotionCollectionView.contentOffset.x)
        let centerPoint = CGPoint(
            x: emotionCollectionView.contentOffset.x + emotionCollectionView.frame.midX,
            y: emotionCollectionView.contentOffset.y)

        guard
            let collectionView = scrollView as? UICollectionView,
            let indexPath = collectionView.indexPathForItem(at: centerPoint)
        else { return }

        let marble = Marble.allCases[indexPath.row]
        emotion = marble

        guard
            let backgrounColor = marble.backgroundColor,
            let textColor = marble.textColor,
            let marbleImage = marble.marbleImage
        else { return }


        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            options: [.curveEaseInOut]
        ) {
            self.emotionMarbleImageView.image = marbleImage
            self.speechImageView.tintColor = backgrounColor
            self.speechLabel.textColor = textColor
            self.speechLabel.text = marble.description
            self.emotionLabel.text = marble.name
            self.emotionLabel.textColor = textColor
            self.emotionLabel.backgroundColor = backgrounColor
        }


    }
}

// MARK: - 아래 내용은 서버 연동 후 없어질 코드 입니다.
enum Marble:String, CaseIterable {
    case NONE
    case CALM
    case VITALITY
    case LETHARGY
    case ANXIETY
    case SATISFACTION
    case FATIGUE

    var backgroundColor: UIColor? {
        switch self {
        case .NONE:
            return BitnagilColor.gray97
        case .CALM:
            return BitnagilColor.purple5
        case .VITALITY:
            return BitnagilColor.green5
        case .LETHARGY:
            return BitnagilColor.gray95
        case .ANXIETY:
            return BitnagilColor.orange50
        case .SATISFACTION:
            return BitnagilColor.mint10
        case .FATIGUE:
            return BitnagilColor.red10
        }
    }

    var textColor: UIColor? {
        switch self {
        case .NONE:
            return BitnagilColor.gray10
        case .CALM:
            return BitnagilColor.purple500
        case .VITALITY:
            return BitnagilColor.green500
        case .LETHARGY:
            return BitnagilColor.gray30
        case .ANXIETY:
            return BitnagilColor.orange500
        case .SATISFACTION:
            return BitnagilColor.mint500
        case .FATIGUE:
            return BitnagilColor.red500
        }
    }

    var marbleImage: UIImage? {
        switch self {
        case .NONE:
            return BitnagilGraphic.marbleNoneGraphic
        case .CALM:
            return BitnagilGraphic.marblePurpleGraphic
        case .VITALITY:
            return BitnagilGraphic.marbleGreenGraphic
        case .LETHARGY:
            return BitnagilGraphic.marbleGrayGraphic
        case .ANXIETY:
            return BitnagilGraphic.marbleOrangeGraphic
        case .SATISFACTION:
            return BitnagilGraphic.marbleMintGraphic
        case .FATIGUE:
            return BitnagilGraphic.marbleRedGraphic
        }
    }

    var name: String {
        switch self {
        case .NONE:
            "구슬 선택"
        case .CALM:
            "평온함"
        case .VITALITY:
            "활기참"
        case .LETHARGY:
            "무기력함"
        case .ANXIETY:
            "불안함"
        case .SATISFACTION:
            "만족함"
        case .FATIGUE:
            "피곤함"
        }
    }

    var koreanDescription: String {
        switch self {
        case .NONE:
            return "구슬 선택"
        case .CALM:
            return "평온한"
        case .VITALITY:
            return "활기찬"
        case .LETHARGY:
            return "무기력한"
        case .ANXIETY:
            return "불안한"
        case .SATISFACTION:
            return "만족하는"
        case .FATIGUE:
            return "피곤한"
        }
    }

    var description: String {
        switch self {
        case .NONE:
            """
            오늘 기분 어때요?
            기록해 두면 내 루틴에 도움 돼요
            """
        case .CALM:
            """
            평온함은 마음이 고요하고 편안해
            균형을 이루는 상태예요.
            """
        case .VITALITY:
            """
            활기참은 생기가 가득 차
            활발하고 적극적인 상태예요.
            """
        case .LETHARGY:
            """
            무기력함은 의욕이 없어 아무것도
            하기 힘든 상태예요.
            """
        case .ANXIETY:
            """
            불안함은 마음이 불안정하고 쉽게
            안심하기 어려운 상태예요.
            """
        case .SATISFACTION:
            """
            만족함은 기대가 충족되어
            더 바랄 것이 없는 상태예요.
            """
        case .FATIGUE:
            """
            피곤함은 몸과 마음이 지쳐
            휴식이 필요한 상태예요.
            """
        }
    }
}
