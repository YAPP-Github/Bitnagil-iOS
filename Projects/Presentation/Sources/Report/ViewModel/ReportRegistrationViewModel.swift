//
//  ReportViewModel.swift
//  Presentation
//
//  Created by 이동현 on 11/9/25.
//

import Combine
import Domain
import Foundation

final class ReportRegistrationViewModel: ViewModel {
    enum Input {
        case selectCategory(type: ReportType)
        case inputTitle(title: String?)
        case inputContent(content: String?)
        case configureLocation
        case selectPhoto(photoData: Data)
        case removePhoto(id: UUID)
        case register
    }

    struct Output {
        let categoryPublisher: AnyPublisher<String?, Never>
        let titlePublisher: AnyPublisher<String?, Never>
        let contentPublisher: AnyPublisher<String?, Never>
        let locationPublisher: AnyPublisher<String?, Never>
        let selectedPhotoPublisher: AnyPublisher<[PhotoItem], Never>
        let isReportValid: AnyPublisher<Bool, Never>
        let exceptionPublisher: AnyPublisher<String, Never>
        let reportRegistrationCompletePublisher: AnyPublisher<Int?, Never>
        let maxPhotoCount: Int
    }

    private(set) var output: Output
    private let reportUseCase: ReportUseCaseProtocol
    private let categorySubject = CurrentValueSubject<ReportType?, Never>(nil)
    private let titleSubject = CurrentValueSubject<String?, Never>(nil)
    private let contentSubject = CurrentValueSubject<String?, Never>(nil)
    private let locationSubject = CurrentValueSubject<String?, Never>(nil)
    private let selectedPhotoSubject = CurrentValueSubject<[PhotoItem], Never>([])
    private let reportVerificationSubject = PassthroughSubject<Bool, Never>()
    private let reportRegistrationCompleteSubject = PassthroughSubject<Int?, Never>()
    private let exceptionSubject = PassthroughSubject<String, Never>()
    private let maxPhotoCount = 3
    private var location: LocationEntity? = nil
    private(set) var selectedReportType: ReportType?

    init(reportUseCase: ReportUseCaseProtocol) {
        self.reportUseCase = reportUseCase

        self.output = Output(
            categoryPublisher: categorySubject.map { $0?.name }.eraseToAnyPublisher(),
            titlePublisher: titleSubject.eraseToAnyPublisher(),
            contentPublisher: contentSubject.eraseToAnyPublisher(),
            locationPublisher: locationSubject.eraseToAnyPublisher(),
            selectedPhotoPublisher: selectedPhotoSubject.eraseToAnyPublisher(),
            isReportValid: reportVerificationSubject.eraseToAnyPublisher(),
            exceptionPublisher: exceptionSubject.eraseToAnyPublisher(),
            reportRegistrationCompletePublisher: reportRegistrationCompleteSubject.eraseToAnyPublisher(),
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
        case .register:
            register()
        }
    }

    private func configureCategory(type: ReportType?) {
        categorySubject.send(type)
        selectedReportType = type
        verifyIsReportValid()
    }

    private func configureTitle(title: String?) {
        titleSubject.send(title)
        verifyIsReportValid()
    }

    private func configureContent(content: String?) {
        contentSubject.send(content)
        verifyIsReportValid()
    }

    private func configureLocation() {
        Task {
            do {
                self.location = try await reportUseCase.fetchCurrentLocation()
                locationSubject.send(location?.address)
                verifyIsReportValid()
            } catch {
                locationSubject.send(nil)
                verifyIsReportValid()
            }
        }
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
        verifyIsReportValid()
    }

    private func removePhoto(id: UUID) {
        let currentSelectedPhoto = selectedPhotoSubject.value.filter { $0.id != id }
        selectedPhotoSubject.send(currentSelectedPhoto)
        verifyIsReportValid()
    }

    private func register() {
        guard
            let name = titleSubject.value,
            !name.isEmpty,
            let category = categorySubject.value,
            let content = contentSubject.value,
            let location,
            selectedPhotoSubject.value.count > 0
        else { return }

        let selectedPhotos = selectedPhotoSubject.value.map({ $0.data })

        Task {
            let minimumDuration: TimeInterval = 0.7
            let startTime = Date()
            let reportId: Int?

            do {
                reportId = try await reportUseCase.report(
                    title: name,
                    content: content,
                    category: category,
                    location: location,
                    photos: selectedPhotos)
            } catch {
                reportId = nil
            }

            let elapsed = Date().timeIntervalSince(startTime)
            if elapsed < minimumDuration {
                let remaining = minimumDuration - elapsed
                try? await Task.sleep(
                    nanoseconds: UInt64(remaining * 1_000_000_000)
                )
            }

            reportRegistrationCompleteSubject.send(reportId)
        }
    }

    private func verifyIsReportValid() {
        guard
            let name = titleSubject.value,
            !name.isEmpty,
            categorySubject.value != nil,
            contentSubject.value != nil,
            let location,
            location.latitude != nil,
            location.longitude != nil,
            selectedPhotoSubject.value.count > 0
        else {
            reportVerificationSubject.send(false)
            return
        }

        reportVerificationSubject.send(true)
    }
}
