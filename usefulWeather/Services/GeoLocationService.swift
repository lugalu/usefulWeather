//Created by Lugalu on 03/11/24.

import SwiftUI
import CoreLocation

protocol GeoLocationInterface {
    var authorizationStatus: CLAuthorizationStatus? {get}
    func getCurrentLocation() throws -> (lat: Double, lon: Double)
}

enum GeoLocationErrors: Error {
    case notAuthorized
}

class GeoLocationService:  NSObject, GeoLocationInterface, Observable, ObservableObject, CLLocationManagerDelegate {
    
    @Published var authorizationStatus: CLAuthorizationStatus?
    private var latitude: CLLocationDegrees = -1
    private var longitude: CLLocationDegrees = -1
    private var locationManager: CLLocationManager = CLLocationManager()

    override init() {
        super.init()
        self.locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways, .authorized:
            authorizationStatus = .authorized
            locationManager.requestLocation()
            break
            
        case .restricted:
            authorizationStatus = .restricted
            break
            
        case .denied:
            authorizationStatus = .denied
            break
            
        case .notDetermined:        // Authorization not determined yet.
            authorizationStatus = .notDetermined
            manager.requestWhenInUseAuthorization()
            break
            
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        stopLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }
    func stopLocation() {
        locationManager.stopUpdatingLocation()
    }
    func getCurrentLocation() throws -> (lat: Double, lon: Double) {
        guard CLAuthorizationStatus.authorized == self.authorizationStatus else {
            throw GeoLocationErrors.notAuthorized
        }
        return (latitude,longitude)
    }
    
}
