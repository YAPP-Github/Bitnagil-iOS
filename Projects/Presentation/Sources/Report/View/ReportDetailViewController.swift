//
//  ReportDetailViewController.swift
//  Presentation
//
//  Created by 최정인 on 11/17/25.
//

import Combine
import SnapKit
import UIKit

class ReportDetailViewController: BaseViewController<ReportDetailViewModel> {
    private enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let photoStackViewSpacing: CGFloat = 8
        static let photoStackViewTopSpacing: CGFloat = 14
        static let photoSize: CGFloat = 74
        static let contentStackViewSpacing: CGFloat = 28
        static let contentStackViewTopSpacing: CGFloat = 23
        static let reportStatusViewTopSpacing: CGFloat = 74
        static let reportStatusViewWidth: CGFloat = 65
        static let reportStatusViewHeight: CGFloat = 26
        static let dateLabelTopSpacing: CGFloat = 6
        static let reportContentBackgroudViewTopSpacing: CGFloat = 8
        static let reportContentDescriptionVerticalMargin: CGFloat = 16
    }

    private enum ReportDetailContent: CaseIterable {
        case title
        case category
        case description
        case location

        var title: String {
            switch self {
            case .title:
                return "제목"
            case .category:
                return "카테고리"
            case .description:
                return "상세 제보 내용"
            case .location:
                return "내 위치"
            }
        }
    }

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let reportStatusView = UIView()
    private let dateLabel = UILabel()
    private let photoStackView = UIStackView()
    private let contentStackView = UIStackView()
    private let titleContentLabel = UILabel()
    private let categoryLabel = UILabel()
    private let detailDescriptionLabel = UILabel()
    private let locationLabel = UILabel()
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.action(input: .fetchReportDetail)
    }

    override func configureAttribute() {
        view.backgroundColor = .white
        configureCustomNavigationBar(navigationBarStyle: .withBackButton(title: "제보하기"))

        scrollView.showsVerticalScrollIndicator = false
        // TODO: 추후 공통 component로 교체
        reportStatusView.layer.masksToBounds = true
        reportStatusView.layer.cornerRadius = 6
        reportStatusView.backgroundColor = BitnagilColor.green10

        dateLabel.font = BitnagilFont(style: .body1, weight: .semiBold).font
        dateLabel.textColor = BitnagilColor.gray10

        photoStackView.axis = .horizontal
        photoStackView.spacing = Layout.photoStackViewSpacing

        contentStackView.axis = .vertical
        contentStackView.spacing = Layout.contentStackViewSpacing

        ReportDetailContent.allCases.forEach { reportDetailContent in
            let reportContentView = makeReportContentView(reportDetailContentType: reportDetailContent)
            contentStackView.addArrangedSubview(reportContentView)
        }
    }

    override func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [reportStatusView, dateLabel, photoStackView, contentStackView].forEach {
            contentView.addSubview($0)
        }

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(safeArea)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        reportStatusView.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(Layout.reportStatusViewTopSpacing)
            make.width.equalTo(Layout.reportStatusViewWidth)
            make.height.equalTo(Layout.reportStatusViewHeight)
            make.leading.equalTo(contentView).offset(Layout.horizontalMargin)
        }

        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(reportStatusView.snp.bottom).offset(Layout.dateLabelTopSpacing)
            make.leading.equalTo(contentView).offset(Layout.horizontalMargin)
        }

        photoStackView.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(Layout.photoStackViewTopSpacing)
            make.leading.equalTo(contentView).offset(Layout.horizontalMargin)
        }

        contentStackView.snp.makeConstraints { make in
            make.top.equalTo(photoStackView.snp.bottom).offset(Layout.contentStackViewTopSpacing)
            make.horizontalEdges.equalTo(contentView).inset(Layout.horizontalMargin)
            make.bottom.equalToSuperview().offset(-40)
        }
    }

    override func bind() {
        viewModel.output.reportDetailPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] reportDetail in
                self?.fillReportContent(reportDetail: reportDetail)
            }
            .store(in: &cancellables)
    }

    private func makeReportContentView(reportDetailContentType: ReportDetailContent) -> UIView {
        let reportContentView = UIView()
        let titleLabel = UILabel()
        let backgroudView = UIView()

        titleLabel.text = reportDetailContentType.title
        titleLabel.font = BitnagilFont(style: .body2, weight: .semiBold).font
        titleLabel.textColor = BitnagilColor.gray10

        backgroudView.layer.masksToBounds = true
        backgroudView.layer.cornerRadius = 12
        backgroudView.backgroundColor = BitnagilColor.gray99

        var descriptionLabel: UILabel
        switch reportDetailContentType {
        case .title:
            descriptionLabel = titleContentLabel
        case .category:
            descriptionLabel = categoryLabel
        case .description:
            descriptionLabel = detailDescriptionLabel
            descriptionLabel.numberOfLines = 0
        case .location:
            descriptionLabel = locationLabel
        }
        descriptionLabel.font = BitnagilFont(style: .body2, weight: .medium).font
        descriptionLabel.textColor = BitnagilColor.gray10

        backgroudView.addSubview(descriptionLabel)
        [titleLabel, backgroudView].forEach {
            reportContentView.addSubview($0)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.height.equalTo(Layout.horizontalMargin)
        }

        backgroudView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Layout.reportContentBackgroudViewTopSpacing)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        descriptionLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(Layout.reportContentDescriptionVerticalMargin)
            make.horizontalEdges.equalToSuperview().inset(Layout.horizontalMargin)
        }

        return reportContentView
    }

    private func fillReportContent(reportDetail: ReportDetail?) {
        guard let reportDetail else { return }

        let photoView = UIView()
        photoView.backgroundColor = BitnagilColor.gray30
        photoView.layer.masksToBounds = true
        photoView.layer.cornerRadius = 9.25
        photoView.snp.makeConstraints { make in
            make.size.equalTo(Layout.photoSize)
        }
        photoStackView.addArrangedSubview(photoView)

        dateLabel.text = reportDetail.date
        titleContentLabel.text = reportDetail.title
        categoryLabel.text = reportDetail.category.name
        detailDescriptionLabel.attributedText = BitnagilFont(style: .body2, weight: .medium).attributedString(text: reportDetail.description)
        locationLabel.text = reportDetail.location
    }
}
