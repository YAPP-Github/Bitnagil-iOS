//
//  LocationRepository.swift
//  DataSource
//
//  Created by 이동현 on 11/9/25.
//

import CoreLocation
import Domain

final class LocationRepository: NSObject, LocationRepositoryProtocol {
    private let networkService = NetworkService.shared
    private let locationManager = CLLocationManager()
    private var continuation: CheckedContinuation<LocationEntity?, Never>?
    private var authContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?

    override init() {
        super.init()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.delegate = self
    }

    func fetchCoordinate() async -> LocationEntity? {
        guard CLLocationManager.locationServicesEnabled() else { return nil }

        let currentStatus = await requestAuthorizationIfNeeded()

        if currentStatus == .authorizedAlways || currentStatus == .authorizedWhenInUse {
            return await withCheckedContinuation { continuation in
                self.continuation = continuation
                locationManager.requestLocation()
            }
        } else {
            return nil
        }
    }

    func fetchAddress(coordinate: LocationEntity) async throws -> LocationEntity? {
        guard
            let longitude = coordinate.longitude,
            let latitude = coordinate.latitude
        else { return nil }

        let endpoint = LocationEndpoint.fetchAddress(longitude: longitude, latitude: latitude)

        guard let response = try await networkService.request(endpoint: endpoint, type: KakaoLocationResponseDTO.self)
        else { return nil }

        let location = response.toLocationEntity(fallbackLongitude: coordinate.longitude, fallbackLatitude: coordinate.latitude)
        return location
    }

    private func requestAuthorizationIfNeeded() async -> CLAuthorizationStatus {
        let currentStatus = locationManager.authorizationStatus

        switch currentStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return currentStatus
        case .denied, .restricted:
            return currentStatus
        case .notDetermined:
            return await withCheckedContinuation { (continuation: CheckedContinuation<CLAuthorizationStatus, Never>) in
                self.authContinuation?.resume(returning: currentStatus)
                self.authContinuation = continuation
                self.locationManager.requestWhenInUseAuthorization()
            }
        default:
            return currentStatus
        }
    }
}

extension LocationRepository: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let coordinate = locations.last?.coordinate
        let entity = coordinate.map { LocationEntity(longitude: $0.longitude, latitude: $0.latitude, address: nil) }
        continuation?.resume(returning: entity)
        continuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        continuation?.resume(returning: nil)
        continuation = nil
    }
}
