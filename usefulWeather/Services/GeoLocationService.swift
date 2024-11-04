//Created by Lugalu on 03/11/24.

import SwiftUI
import CoreLocation

protocol GeoLocationInterface {
    var currentLocation: CLLocation { get async throws }
    var authorizationStatus: CLAuthorizationStatus { get async }
    func checkAuthorization()
}

enum GeoLocationErrors: Error {
    case notAuthorized
}

class GeoLocationService:  NSObject, GeoLocationInterface, Observable, ObservableObject, CLLocationManagerDelegate {
    
    private let locationManager: CLLocationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocation,Error>? = nil
    private var authContinuation: CheckedContinuation<CLAuthorizationStatus, Never>? = nil
    
    var currentLocation: CLLocation {
        get async throws {
            return try await withCheckedThrowingContinuation{ continuation in
                self.locationContinuation = continuation
                self.locationManager.requestLocation()
            }
        }
    }
    
    var authorizationStatus: CLAuthorizationStatus {
        get async {
            return await withCheckedContinuation{ continuation in
                let status =  locationManager.authorizationStatus
                if status == .notDetermined {
                    self.authContinuation = continuation
                    self.locationManager.requestWhenInUseAuthorization()
                }else {
                    continuation.resume(returning: status)
                }
            }
        }
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func checkAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            return
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let auth = manager.authorizationStatus
        authContinuation?.resume(returning: auth)
        authContinuation = nil
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationContinuation?.resume(returning: location)
            locationContinuation = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        locationContinuation?.resume(throwing: error)
        locationContinuation = nil
    }
}
