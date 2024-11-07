//Created by Lugalu on 01/11/24.

import SwiftUI
import SwiftData
import CoreLocation

class WeatherModel: ObservableObject, Observable {
    @Published var weatherData: WeatherData?
    @Published var locationAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    let networkingService: NetworkInterface
    let decoderService: DecoderService
    let databaseService: ModelContainer
    let locationService: GeoLocationInterface
    
    init(locator: ServiceLocator) {
        self.networkingService = locator.getNetworkService()
        self.decoderService = locator.getDecoderService()
        self.databaseService = locator.getDatabaseService()
        self.locationService = locator.getGeoLocationService()
        locationService.checkAuthorization()
    }
    
    
    func fetchWeather() async throws {
        let authorizationStatus = await locationService.authorizationStatus
        
        guard checkForAuth(authorizationStatus) else {
            Task { @MainActor in
                locationAuthorizationStatus = .denied
            }
            return
        }
        
        Task { @MainActor in
            locationAuthorizationStatus = authorizationStatus
        }
        
        let (latitude, longitude) = try await getLatitudeAndLongitude()
        let testData = exampleJSON.data(using: .ascii)!
        let json = try decoderService.decode(testData, class: WeatherJSON.self)
        let weather = WeatherMapper.map(from: json)
//                let data = try await networkingService.downloadData(from: .currentLocation(latitude: latitude, longitude: longitude))
//                let json = try decoderService.decode(data, class: WeatherJSON.self)
//                let weather = WeatherMapper.map(from: json)
        Task{ @MainActor in
            self.weatherData = weather
        }
    }
    
    private func getLatitudeAndLongitude() async throws -> (String,String){
        let location = try await locationService.currentLocation
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude

        let nsLatitude = NSNumber(value: latitude)
        let nsLongitude = NSNumber(value: longitude)

        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = "."

        guard let latitudeString = formatter.string(from: nsLatitude), let longitudeString = formatter.string(from: nsLongitude) else {
            throw NetworkErrors.unknowError
        }
        return (latitudeString, longitudeString)
    }
    
    private func checkForAuth(_ status: CLAuthorizationStatus) -> Bool {
        #if os(macOS)
            return status == .authorized || status == .authorizedAlways
        #else
            return status == .authorizedAlways || status == .authorizedWhenInUse
        #endif
    }
    
    func checkForAuth() -> Bool {
        #if os(macOS)
        return locationAuthorizationStatus == .authorized || locationAuthorizationStatus == .authorizedAlways
        #else
        return locationAuthorizationStatus == .authorizedWhenInUse || locationAuthorizationStatus == .authorizedAlways
        #endif
    }
    
    func didAuthHappen() -> Bool {
        return locationAuthorizationStatus != .notDetermined
    }
    
}

