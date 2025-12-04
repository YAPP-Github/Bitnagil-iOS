//
//  ReportCompleteViewController.swift
//  Presentation
//
//  Created by 최정인 on 11/19/25.
//

import Combine
import Shared
import SnapKit
import UIKit

final class ReportCompleteViewController: BaseViewController<ReportDetailViewModel> {
    private enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let completeImageViewTopSpacing: CGFloat = 78
        static let completeImageViewSize: CGFloat = 40
        static let completeLabelTopSpacing: CGFloat = 12
        static let subLableTopSpacing: CGFloat = 16
        static let fomoImageViewTopSpacing: CGFloat = 34
        static let backgroundViewTopSpacing: CGFloat = 82
        static let backgroundViewBottomSpacing: CGFloat = 66
        static let summaryStackViewTopSpacing: CGFloat = 20
        static let summaryStackViewSpacing: CGFloat = 20
        static let summaryStackViewBottomSpacing: CGFloat = 20
        static let photoStackViewSpacing: CGFloat = 6
        static let photoSize: CGFloat = 48
        static let confirmButtonHeight: CGFloat = 54
        static let confirmButtonBottomSpacing: CGFloat = 14
    }

    private enum ReportCompleteContent: CaseIterable {
        case title
        case category
        case location
        case description
        case photos

        var titleString: String {
            switch self {
            case .title:
                return "제목"
            case .category:
                return "카테고리"
            case .location:
                return "신고 위치"
            case .description:
                return "제보 내용"
            case .photos:
                return "제보 사진"
            }
        }
    }

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let completeImageView = UIImageView()
    private let completeLabel = UILabel()
    private let subLabel = UILabel()
    private let fomoImageView = UIImageView()
    private let backgroudView = UIView()
    private let summaryStackView = UIStackView()
    private let summaryLabel = UILabel()
    private let titleLabel = UILabel()
    private let categoryLabel = UILabel()
    private let locationLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let photoStackView = UIStackView()
    private let confirmButton = PrimaryButton(buttonState: .default, buttonTitle: "확인")
    private let reportId: Int
    private var cancellables: Set<AnyCancellable> = []

    init(viewModel: ReportDetailViewModel, reportId: Int) {
        self.reportId = reportId

        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAttribute()
        configureLayout()
        viewModel.action(input: .fetchReportDetail(reportId: reportId))
    }

    override func configureAttribute() {
        view.backgroundColor = .white
        scrollView.showsVerticalScrollIndicator = false

        completeImageView.image = BitnagilIcon.completeIcon

        completeLabel.text = "제보가 완료되었습니다"
        completeLabel.font = BitnagilFont(style: .title2, weight: .bold).font
        completeLabel.textColor = BitnagilColor.gray10

        subLabel.numberOfLines = 2
        subLabel.attributedText = BitnagilFont(style: .body1, weight: .medium)
            .attributedString(text: "빛나길에서 접수 후 완료되면\n신고를 진행합니다.", alignment: .center)
        subLabel.textColor = BitnagilColor.gray40

        fomoImageView.image = BitnagilGraphic.successFomoGraphic

        backgroudView.backgroundColor = BitnagilColor.gray98
        backgroudView.layer.masksToBounds = true
        backgroudView.layer.cornerRadius = 12

        summaryStackView.axis = .vertical
        summaryStackView.spacing = Layout.summaryStackViewSpacing

        summaryLabel.text = "제보 요약정보"
        summaryLabel.font = BitnagilFont(style: .body2, weight: .semiBold).font
        summaryLabel.textColor = BitnagilColor.gray10

        photoStackView.axis = .horizontal
        photoStackView.spacing = Layout.photoStackViewSpacing

        confirmButton.addAction(
            UIAction { [weak self] _ in
                if
                    let self,
                    let tabBarController = self.tabBarController,
                    let homeViewController = tabBarController.viewControllers?[0] as? UINavigationController,
                    let recommendedRoutineViewController = tabBarController.viewControllers?[1] as? UINavigationController,
                    let mypageViewController = tabBarController.viewControllers?[2] as? UINavigationController,
                    let reportHistoryViewModel = DIContainer.shared.resolve(type: ReportHistoryViewModel.self) {

                    homeViewController.popToRootViewController(animated: false)
                    recommendedRoutineViewController.popToRootViewController(animated: false)

                    tabBarController.selectedIndex = 2
                    let reportHistoryViewController = ReportHistoryViewController(viewModel: reportHistoryViewModel)
                    mypageViewController.pushViewController(reportHistoryViewController, animated: true)
                } else {
                    self?.navigationController?.popToRootViewController(animated: true)
                }
            },
            for: .touchUpInside)
    }

    override func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [completeImageView, completeLabel, subLabel, fomoImageView, backgroudView, confirmButton].forEach {
            contentView.addSubview($0)
        }

        backgroudView.addSubview(summaryStackView)
        summaryStackView.addArrangedSubview(summaryLabel)

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(safeArea)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        completeImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Layout.completeImageViewTopSpacing)
            make.centerX.equalToSuperview()
            make.size.equalTo(Layout.completeImageViewSize)
        }

        completeLabel.snp.makeConstraints { make in
            make.top.equalTo(completeImageView.snp.bottom).offset(Layout.completeLabelTopSpacing)
            make.centerX.equalToSuperview()
        }

        subLabel.snp.makeConstraints { make in
            make.top.equalTo(completeLabel.snp.bottom).offset(Layout.subLableTopSpacing)
            make.centerX.equalToSuperview()
        }

        fomoImageView.snp.makeConstraints { make in
            make.top.equalTo(subLabel.snp.bottom).offset(Layout.fomoImageViewTopSpacing)
            make.centerX.equalToSuperview()
        }

        backgroudView.snp.makeConstraints { make in
            make.top.equalTo(fomoImageView).offset(Layout.backgroundViewTopSpacing)
            make.horizontalEdges.equalToSuperview().inset(Layout.horizontalMargin)
            make.bottom.equalTo(confirmButton.snp.top).offset(-Layout.backgroundViewBottomSpacing)
        }

        summaryStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Layout.summaryStackViewTopSpacing)
            make.horizontalEdges.equalToSuperview().inset(Layout.horizontalMargin)
            make.bottom.equalToSuperview().offset(-Layout.summaryStackViewBottomSpacing)
        }

        confirmButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(Layout.horizontalMargin)
            make.height.equalTo(Layout.confirmButtonHeight)
            make.bottom.equalToSuperview().offset(-Layout.confirmButtonBottomSpacing)
        }
    }

    override func bind() {
        viewModel.output.reportDetailPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] reportDetail in
                guard let reportDetail else { return }

                self?.titleLabel.text = reportDetail.title
                self?.categoryLabel.text = reportDetail.category.name
                self?.locationLabel.text = reportDetail.location
                let descriptionText = reportDetail.description
                self?.descriptionLabel.numberOfLines = 0
                self?.descriptionLabel.attributedText = BitnagilFont(style: .body1, weight: .medium)
                    .attributedString(text: descriptionText, alignment: .right)

                ReportCompleteContent.allCases.forEach { reportCompleteContentType in
                    let contentStackView = self?.makeContentView(contentType: reportCompleteContentType)
                    self?.summaryStackView.addArrangedSubview(contentStackView ?? UIView())
                }

                self?.photoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                for photoURL in reportDetail.photoUrls {
                    guard
                        let photoView = self?.makePhotoView(),
                        let url = URL(string: photoURL)
                    else { continue }

                    photoView.kf.setImage(with: url)
                    self?.photoStackView.addArrangedSubview(photoView)
                }
            })
            .store(in: &cancellables)
    }

    private func makeContentView(contentType: ReportCompleteContent) -> UIView {
        let contentContainerView = UIView()
        let contentTitleLabel = UILabel()

        contentTitleLabel.text = contentType.titleString
        contentTitleLabel.font = BitnagilFont(style: .body1, weight: .medium).font
        contentTitleLabel.textColor = BitnagilColor.gray30

        contentContainerView.addSubview(contentTitleLabel)
        contentTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        var contentView: UIView
        if contentType == .photos {
            contentView = photoStackView
        } else {
            var contentLabel = UILabel()
            switch contentType {
            case .title:
                contentLabel = titleLabel
            case .category:
                contentLabel = categoryLabel
            case .location:
                contentLabel = locationLabel
            case .description:
                contentLabel = descriptionLabel
                contentLabel.numberOfLines = 0
                contentTitleLabel.setContentHuggingPriority(.required, for: .horizontal)
                descriptionLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            case .photos:
                break
            }
            contentView = contentLabel
        }

        contentContainerView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(contentTitleLabel.snp.trailing).offset(12)
            make.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }

        return contentContainerView
    }

    private func makePhotoView() -> UIImageView {
        let photoView = UIImageView()
        photoView.backgroundColor = BitnagilColor.gray30
        photoView.layer.masksToBounds = true
        photoView.layer.cornerRadius = 6
        photoView.snp.makeConstraints { make in
            make.size.equalTo(Layout.photoSize)
        }
        return photoView
    }
}
