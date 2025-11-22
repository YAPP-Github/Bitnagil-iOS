//
//  ReportViewController.swift
//  Presentation
//
//  Created by 이동현 on 11/8/25.
//

import Combine
import Domain
import PhotosUI
import SnapKit
import UIKit

protocol ReportRegistrationViewControllerDelegate: AnyObject {
    func reportRegistrationViewController(_ sender: ReportRegistrationViewController, completeRegistration reportId: Int?)
}

final class ReportRegistrationViewController: BaseViewController<ReportRegistrationViewModel> {
    private enum CollectionViewSection { case main }

    private enum Layout {
        static let horizontalInset: CGFloat = 20
        static let navigationBarBottomSpacing: CGFloat = 80
        static let titleLabelTopSpacing: CGFloat = 28
        static let titleLabelBottomSpacing: CGFloat = 8
        static let titleLabelHeight: CGFloat = 24
        static let cameraButtonTopSpacing: CGFloat = 8
        static let cameraButtonSize: CGFloat = 64
        static let cameraButtonCornerRadius: CGFloat = 8
        static let reportPhotoCollectionViewTopSpacing: CGFloat = 1
        static let reportCollectionLeadingSpacing: CGFloat = 14
        static let reportCollectionViewCellSize: CGFloat = 72
        static let reportCollectionViewCellSpacing: CGFloat = 7
        static let reportCollectionViewHeight: CGFloat = 72
        static let inputViewCornerRadius: CGFloat = 12
        static let textViewHeight: CGFloat = 52
        static let reportContentTextViewHeight: CGFloat = 88
        static let locationButtonSize: CGFloat = 52
        static let locationButtonLeadingSpacing: CGFloat = 12
        static let locationButtonCornerRadius: CGFloat = 12
        static let registerButtonCornerRadius: CGFloat = 12
        static let registerButtonTopSpacing: CGFloat = 47
        static let registerButtonBottomSpacing: CGFloat = 14
        static let registerButtonHeight: CGFloat = 54
        static let categoryBottomSheetHeight: CGFloat = 362
        static let cameraBottomSheetHeight: CGFloat = 174
        static let contentCountLabelTopSpacing: CGFloat = 6
        static let contentCountLabelHeight: CGFloat = 18
    }

    private typealias Section = ReportRegistrationViewController.CollectionViewSection
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, PhotoItem>
    private typealias Snapshot  = NSDiffableDataSourceSnapshot<Section, PhotoItem>

    private let scrollView = UIScrollView()
    private let scrollContentView = UIView()
    private let collectionViewTitleLabel = RequiredTitleLabel(title: "제보사진 등록")
    private let categoryTitleLabel = RequiredTitleLabel(title: "제보 카테고리")
    private let nameTitleLabel = RequiredTitleLabel(title: "제목")
    private let contentTitleLabel = RequiredTitleLabel(title: "제보 내용")
    private let locationTitleLabel = RequiredTitleLabel(title: "신고 위치")
    private let cameraButton = ReportCameraButton(frame: .zero)
    private let photoCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    private let categoryTextView = ReportTextView(type: .combo, placeholder: "카테고리 선택")
    private let reportTitleTextView = ReportTextView(type: .editable, placeholder: "제보 제목을 작성해주세요.")
    private let reportContentTextView = ReportTextView(type: .editable, placeholder: "어떤 위험인지 간단히 설명해주세요.")
    private let locationTextView = ReportTextView(type: .nonEditable, placeholder: "현재 위치 검색")
    private let contentTextCountLabel = UILabel()
    private let locationButton = LocationButton()
    private let registerButton = PrimaryButton(buttonState: .disabled, buttonTitle: "제출하기")
    private let photoSelectionView = SelectableItemTableView<SelectPhotoType>(items: SelectPhotoType.allCases.sorted(by: { $0.id < $1.id }), markIsSelected: false)
    private var cancellables: Set<AnyCancellable> = []
    private var dataSource: DataSource?
    weak var delegate: ReportRegistrationViewControllerDelegate?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureCustomNavigationBar(navigationBarStyle: .withBackButton(title: "제보하기"))
    }

    override func configureAttribute() {
        configureCollectionViewDataSource()
        configurePhotoCollectionLayout()

        view.backgroundColor = .white

        scrollView.showsVerticalScrollIndicator = false
        photoCollectionView.delegate = self

        [
            categoryTextView,
            locationTextView,
            reportTitleTextView,
            reportContentTextView].forEach { textView in
                textView.layer.cornerRadius = Layout.inputViewCornerRadius
                textView.layer.masksToBounds = true
                textView.delegate = self
            }

        cameraButton.layer.cornerRadius = Layout.locationButtonCornerRadius
        cameraButton.layer.masksToBounds = true
        cameraButton.addAction(
            UIAction { [weak self] _ in
                self?.showCameraBottomSheet()
            },
            for: .touchUpInside)

        locationButton.layer.cornerRadius = Layout.locationButtonCornerRadius
        locationButton.layer.masksToBounds = true
        locationButton.addAction(
            UIAction { [weak self] _ in
                self?.viewModel.action(input: .configureLocation)
            },
            for: .touchUpInside)

        registerButton.layer.cornerRadius = Layout.registerButtonCornerRadius
        registerButton.layer.masksToBounds = true
        registerButton.addAction(
            UIAction { [weak self] _ in
                let loadingViewController = ReportLoadingViewController()
                self?.delegate = loadingViewController
                self?.navigationController?.pushViewController(loadingViewController, animated: true)
                self?.viewModel.action(input: .register)
            },
            for: .touchUpInside)

        contentTextCountLabel.font = BitnagilFont.init(style: .caption1, weight: .medium).font
        contentTextCountLabel.textColor = BitnagilColor.gray80

        photoSelectionView.delegate = self
        applySnapshot(items: [], animating: false)
    }

    override func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(collectionViewTitleLabel)
        scrollContentView.addSubview(categoryTitleLabel)
        scrollContentView.addSubview(nameTitleLabel)
        scrollContentView.addSubview(contentTitleLabel)
        scrollContentView.addSubview(locationTitleLabel)
        scrollContentView.addSubview(cameraButton)
        scrollContentView.addSubview(photoCollectionView)
        scrollContentView.addSubview(categoryTextView)
        scrollContentView.addSubview(reportTitleTextView)
        scrollContentView.addSubview(reportContentTextView)
        scrollContentView.addSubview(contentTextCountLabel)
        scrollContentView.addSubview(locationTextView)
        scrollContentView.addSubview(locationButton)
        scrollContentView.addSubview(registerButton)

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(safeArea)
        }

        scrollContentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
            make.height.equalTo(scrollView.frameLayoutGuide).priority(.low)
        }

        collectionViewTitleLabel.snp.makeConstraints { make in
            make.top
                .equalToSuperview()
                .offset(Layout.navigationBarBottomSpacing)

            make.leading
                .equalToSuperview()
                .offset(Layout.horizontalInset)

            make.height
                .equalTo(Layout.titleLabelHeight)
        }

        cameraButton.snp.makeConstraints { make in
            make.top
                .equalTo(collectionViewTitleLabel.snp.bottom)
                .offset(Layout.cameraButtonTopSpacing)

            make.leading
                .equalToSuperview()
                .offset(Layout.horizontalInset)

            make.size.equalTo(Layout.cameraButtonSize)
        }

        photoCollectionView.snp.makeConstraints { make in
            make.top
                .equalTo(collectionViewTitleLabel.snp.bottom)
                .offset(Layout.reportPhotoCollectionViewTopSpacing)

            make.leading
                .equalTo(cameraButton.snp.trailing)
                .offset(Layout.reportCollectionLeadingSpacing)

            make.trailing
                .equalToSuperview()
                .inset(Layout.horizontalInset)

            make.height
                .equalTo(Layout.reportCollectionViewHeight)
        }

        nameTitleLabel.snp.makeConstraints { make in
            make.top
                .equalTo(cameraButton.snp.bottom)
                .offset(Layout.titleLabelTopSpacing)

            make.leading
                .equalToSuperview()
                .offset(Layout.horizontalInset)

            make.height
                .equalTo(Layout.titleLabelHeight)
        }

        reportTitleTextView.snp.makeConstraints { make in
            make.top
                .equalTo(nameTitleLabel.snp.bottom)
                .offset(Layout.titleLabelBottomSpacing)

            make.horizontalEdges
                .equalToSuperview()
                .inset(Layout.horizontalInset)

            make.height
                .equalTo(Layout.textViewHeight)
        }

        categoryTitleLabel.snp.makeConstraints { make in
            make.top
                .equalTo(reportTitleTextView.snp.bottom)
                .offset(Layout.titleLabelTopSpacing)

            make.leading
                .equalToSuperview()
                .offset(Layout.horizontalInset)

            make.height
                .equalTo(Layout.titleLabelHeight)
        }

        categoryTextView.snp.makeConstraints { make in
            make.top
                .equalTo(categoryTitleLabel.snp.bottom)
                .offset(Layout.titleLabelBottomSpacing)

            make.horizontalEdges
                .equalToSuperview()
                .inset(Layout.horizontalInset)

            make.height
                .equalTo(Layout.textViewHeight)
        }

        contentTitleLabel.snp.makeConstraints { make in
            make.top
                .equalTo(categoryTextView.snp.bottom)
                .offset(Layout.titleLabelTopSpacing)

            make.leading
                .equalToSuperview()
                .offset(Layout.horizontalInset)

            make.height
                .equalTo(Layout.titleLabelHeight)
        }

        reportContentTextView.snp.makeConstraints { make in
            make.top
                .equalTo(contentTitleLabel.snp.bottom)
                .offset(Layout.titleLabelBottomSpacing)

            make.horizontalEdges
                .equalToSuperview()
                .inset(Layout.horizontalInset)

            make.height
                .equalTo(Layout.reportContentTextViewHeight)
                .priority(.medium)
        }

        contentTextCountLabel.snp.makeConstraints { make in
            make.top
                .equalTo(reportContentTextView.snp.bottom)
                .offset(Layout.contentCountLabelTopSpacing)

            make.trailing
                .equalToSuperview()
                .offset(-Layout.horizontalInset)

            make.height.equalTo(Layout.contentCountLabelHeight)
        }

        locationTitleLabel.snp.makeConstraints { make in
            make.top
                .equalTo(reportContentTextView.snp.bottom)
                .offset(Layout.titleLabelTopSpacing)

            make.leading
                .equalToSuperview()
                .offset(Layout.horizontalInset)

            make.height
                .equalTo(Layout.titleLabelHeight)
        }

        locationButton.snp.makeConstraints { make in
            make.top
                .equalTo(locationTitleLabel.snp.bottom)
                .offset(Layout.titleLabelBottomSpacing)

            make.trailing
                .equalToSuperview()
                .inset(Layout.horizontalInset)

            make.size
                .equalTo(Layout.locationButtonSize)
        }

        locationTextView.snp.makeConstraints { make in
            make.leading
                .equalToSuperview()
                .offset(Layout.horizontalInset)

            make.trailing
                .equalTo(locationButton.snp.leading)
                .offset(-Layout.locationButtonLeadingSpacing)

            make.top
                .equalTo(locationButton)

            make.height
                .equalTo(Layout.textViewHeight)
        }

        registerButton.snp.makeConstraints { make in
            make.horizontalEdges
                .equalToSuperview()
                .inset(Layout.horizontalInset)

            make.top
                .greaterThanOrEqualTo(locationTextView.snp.bottom)
                .offset(Layout.registerButtonTopSpacing)

            make.bottom
                .equalToSuperview()
                .inset(Layout.registerButtonBottomSpacing)

            make.height
                .equalTo(Layout.registerButtonHeight)
        }
    }

    override func bind() {
        viewModel.output.categoryPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] category in
                self?.categoryTextView.configure(text: category ?? "")
            }
            .store(in: &cancellables)

        viewModel.output.titlePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.reportTitleTextView.configure(text: title ?? "")
            }
            .store(in: &cancellables)

        viewModel.output.contentPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] content in
                self?.reportContentTextView.configure(text: content ?? "")

                let content = content ?? ""
                self?.contentTextCountLabel.text = "\(content.count) / 150"
            }
            .store(in: &cancellables)

        viewModel.output.locationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] address in
                self?.locationTextView.configure(text: address ?? "")
            }
            .store(in: &cancellables)

        viewModel.output.exceptionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                let alertController = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "확인", style: .default))
                self?.present(alertController, animated: true)
            }
            .store(in: &cancellables)

        viewModel.output.selectedPhotoPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                guard let self else { return }
                self.applySnapshot(items: items, animating: true)
                self.cameraButton
                    .configure(imageCount: items.count, maxCount: viewModel.output.maxPhotoCount)
            }
            .store(in: &cancellables)

        viewModel.output.isReportValid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isReportValid in
                if isReportValid {
                    self?.registerButton.updateButtonState(buttonState: .default)
                } else {
                    self?.registerButton.updateButtonState(buttonState: .disabled)
                }
            }
            .store(in: &cancellables)

        viewModel.output.reportRegistrationCompletePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] reportId in
                guard let self else { return }

                delegate?.reportRegistrationViewController(self, completeRegistration: reportId)
            }
            .store(in: &cancellables)
    }

    private func showCameraBottomSheet() {
        presentCustomBottomSheet(contentViewController: photoSelectionView, maxHeight: Layout.cameraBottomSheetHeight)
    }

    private func showCategoryBottomSheet() {
        let categorySelectionView = ReportCategoryTableViewController(reportType: viewModel.selectedReportType)
        categorySelectionView.delegate = self
        presentCustomBottomSheet(contentViewController: categorySelectionView, maxHeight: Layout.categoryBottomSheetHeight)
    }

    private func configureCollectionViewDataSource() {
        let registration = UICollectionView.CellRegistration<ReportPhotoCollectionViewCell, PhotoItem> { cell, _, item in
            cell.configure(with: item)
            cell.delegate = self
        }

        dataSource = DataSource(collectionView: photoCollectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
        }
        photoCollectionView.dataSource = dataSource
    }

    private func configurePhotoCollectionLayout() {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(Layout.reportCollectionViewCellSize),
            heightDimension: .absolute(Layout.reportCollectionViewCellSize)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .estimated(Layout.reportCollectionViewCellSize),
            heightDimension: .estimated(Layout.reportCollectionViewCellSize)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(Layout.reportCollectionViewCellSpacing)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .zero
        section.interGroupSpacing = .zero
        section.orthogonalScrollingBehavior = .continuous

        let layout = UICollectionViewCompositionalLayout(section: section)
        photoCollectionView.setCollectionViewLayout(layout, animated: false)
    }

    private func applySnapshot(items: [PhotoItem], animating: Bool) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }

    private func presentCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            let alertController = UIAlertController(title: "카메라 사용 불가", message: "이 기기에서 카메라를 사용할 수 없습니다.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "확인", style: .default))
            present(alertController, animated: true)
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = false
        picker.delegate = self
        present(picker, animated: true)
    }

    private func presentPhotoPicker() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 3
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func dismissIfNeededThen(_ action: @escaping () -> Void) {
        if Thread.isMainThread {
            if let presented = presentedViewController {
                presented.dismiss(animated: true, completion: action)
            } else {
                action()
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.dismissIfNeededThen(action)
            }
        }
    }
}

extension ReportRegistrationViewController: ReportTextViewDelegate {
    func reportTextViewDidChanged(_ reportTextView: ReportTextView, text: String?) {
        switch reportTextView {
        case reportTitleTextView:
            viewModel.action(input: .inputTitle(title: text))
        case reportContentTextView:
            viewModel.action(input: .inputContent(content: text))
        default: return
        }
    }

    func reportTextViewDidTapped(_ reportTextView: ReportTextView) {
        showCategoryBottomSheet()
    }
}

extension ReportRegistrationViewController: ReportPhotoCollectionViewCellDelegate {
    func reportPhotoCollectionViewCellWillDeleteCell(_ cell: ReportPhotoCollectionViewCell, uuid: UUID) {
        viewModel.action(input: .removePhoto(id: uuid))
    }
}

extension ReportRegistrationViewController: UICollectionViewDelegate {

}

extension ReportRegistrationViewController: ReportCategoryTableViewControllerDelegate {
    func reportCategoryTableViewController(_ sender: ReportCategoryTableViewController, selectedCategory: ReportType?) {
        guard let selectedCategory else { return }
        viewModel.action(input: .selectCategory(type: selectedCategory))
    }
}

extension ReportRegistrationViewController: SelectableItemTableViewDelegate {
    func selectableItemTableView<T>(_ sender: SelectableItemTableView<T>, didSelectItem: T?) where T : SelectableItem, T : CaseIterable, T : Equatable {
        if
            T.self == ReportType.self,
            let item = didSelectItem as? ReportType
        {
            viewModel.action(input: .selectCategory(type: item))

        } else if
            T.self == SelectPhotoType.self,
            let item = didSelectItem as? SelectPhotoType
        {
            switch item {
            case .camera:
                dismissIfNeededThen { [weak self] in
                    self?.presentCamera()
                }
            case .library:
                dismissIfNeededThen { [weak self] in
                    self?.presentPhotoPicker()
                }
            }
        }
    }
}

extension ReportRegistrationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer { picker.dismiss(animated: true) }

        guard
            let image = info[.originalImage] as? UIImage,
            let data = image.jpegData(compressionQuality: 0.5)
        else { return }

        viewModel.action(input: .selectPhoto(photoData: data))
    }
}

extension ReportRegistrationViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        guard
            let itemProvider = results.first?.itemProvider,
            itemProvider.canLoadObject(ofClass: UIImage.self)
        else { return }

        itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
            guard
                let selectedImage = image as? UIImage,
                let imageData = selectedImage.jpegData(compressionQuality: 0.5)
            else { return }

            DispatchQueue.main.async {
                self.viewModel.action(input: .selectPhoto(photoData: imageData))
            }
        }
    }
}
