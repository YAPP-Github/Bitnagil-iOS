//
//  ReportViewModel.swift
//  Presentation
//
//  Created by 이동현 on 11/9/25.
//

import Combine
import Domain
import Foundation

final class ReportViewModel: ViewModel {
    enum Input {
        case selectCategory(type: ReportType)
        case inputTitle(title: String?)
        case inputContent(content: String?)
        case configureLocation
        case selectPhoto(photoData: Data)
        case removePhoto(id: UUID)
    }

    struct Output {
        let categoryPublisher: AnyPublisher<String?, Never>
        let titlePublisher: AnyPublisher<String?, Never>
        let contentPublisher: AnyPublisher<String?, Never>
        let locationPublisher: AnyPublisher<String?, Never>
        let selectedPhotoPublisher: AnyPublisher<[PhotoItem], Never>
        let exceptionPublisher: AnyPublisher<String, Never>
        let maxPhotoCount: Int
    }

    private(set) var output: Output
    private let categorySubject = CurrentValueSubject<ReportType?, Never>(nil)
    private let titleSubject = CurrentValueSubject<String?, Never>(nil)
    private let contentSubject = CurrentValueSubject<String?, Never>(nil)
    private let locationSubject = CurrentValueSubject<String?, Never>(nil)
    private let selectedPhotoSubject = CurrentValueSubject<[PhotoItem], Never>([])
    private let exceptionSubject = PassthroughSubject<String, Never>()
    private let maxPhotoCount = 3
    private var latitude: Double? = nil
    private var longitude: Double? = nil

    init() {
        self.output = Output(
            categoryPublisher: categorySubject.map { $0?.description }.eraseToAnyPublisher(),
            titlePublisher: titleSubject.eraseToAnyPublisher(),
            contentPublisher: contentSubject.eraseToAnyPublisher(),
            locationPublisher: locationSubject.eraseToAnyPublisher(),
            selectedPhotoPublisher: selectedPhotoSubject.eraseToAnyPublisher(),
            exceptionPublisher: exceptionSubject.eraseToAnyPublisher(),
            maxPhotoCount: maxPhotoCount)
    }

    func action(input: Input) {
        switch input {
        case .selectCategory(let type):
            configureCategory(type: type)
        case .inputTitle(let title):
            configureTitle(title: title)
        case .inputContent(let content):
            configureContent(content: content)
        case .configureLocation:
            configureLocation()
        case .selectPhoto(let photoData):
            selectPhoto(photoData: photoData)
        case .removePhoto(let id):
            removePhoto(id: id)
        }
    }

    private func configureCategory(type: ReportType?) {
        categorySubject.send(type)
    }

    private func configureTitle(title: String?) {
        titleSubject.send(title)
    }

    private func configureContent(content: String?) {
        contentSubject.send(content)
    }

    private func configureLocation() {
        // 카카오 sdk로 현 위치 설정
    }

    private func selectPhoto(photoData: Data?) {
        guard let photoData else { return }
        var currentSelectedPhoto = selectedPhotoSubject.value

        guard currentSelectedPhoto.count < maxPhotoCount else {
            exceptionSubject.send("사진은 최대 \(maxPhotoCount)장까지 선택할 수 있습니다.")
            return
        }

        let item = PhotoItem(data: photoData)
        currentSelectedPhoto.append(item)

        selectedPhotoSubject.send(currentSelectedPhoto)
    }

    private func removePhoto(id: UUID) {
        let currentSelectedPhoto = selectedPhotoSubject.value.filter { $0.id != id }
        selectedPhotoSubject.send(currentSelectedPhoto)
    }
}
