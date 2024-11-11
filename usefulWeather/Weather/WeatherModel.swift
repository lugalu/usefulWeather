//Created by Lugalu on 01/11/24.

import SwiftUI
import SwiftData
import CoreLocation

class WeatherModel: ObservableObject, Observable {
    @Published var weatherData: WeatherData?
    @Published var recommendedClothing: [String] = []
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
            self.calculateClothing()
        }
    }
    
    private func getLatitudeAndLongitude() async throws -> (String,String) {
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
    

    
    func calculateClothing() {
        guard let weatherData, let feelslike = weatherData.temperature.feelsLike else { return }
//        let categories: [[String]] = [
//            ["Light or protective clothes are a must."," Sunscreen is mandatory for light-skinned folks."," Dresses, t-shirts, shirts, shorts, etc."], //1 and 2?
//            ["Light clothes are recommended."," Sunscreen is highly recommendedfor light-skinned folks."," Dresses, t-shirts, shirts, shorts, etc."], //3 to 4
//            ["Medium clothing are recommended.", "If you are a person who feels more cold than most it's a good idea to carry a jacket", "Pants, t-shirts, blazers, jackets, etc."], // 5 and 6
//            [""]
//        ]
        
        var categoryIdx = getCategory(feelslike)
        if shouldIncreaseIdx(categoryIdx, humidity: weatherData.temperature.humidity) {
            categoryIdx += 1
        }
        
        //TODO: figure out what to display!
        
        let upperBody = ["shirt", "t-shirt", "t-shirt with blazer", "jackets", "sweater", "noodles"] [categoryIdx % 6]
        let print = ["floral","vertical", "horizontal",  "drawning", "plaid", "plain"] [categoryIdx % 6]
        let lowerBody = ["skirt", "shorts","jeans", "leggings", "insulated pants"] [categoryIdx % 5]
        let material = ["chiffon", "fiber", "cotton", "denim", "woolen", "leather"] [categoryIdx % 6]

    }
    
    func clamp<T: Numeric & Comparable>( _ minV: T, _ value: T, _ maxV: T) -> T {
        return min(maxV, max(minV, value))
    }
    
    private func getCategory(_ feelslike: Double) -> Int {
        return switch feelslike {
        case (33...) :
            1
        case (28...) :
            2
        case (25...) :
            3
        case (23...) :
            4
        case (21...) :
            5
        case (18...) :
            6
        case (15...) :
            7
        case (13...) :
            8
        case (9...) :
            9
        case (6...) :
            10
        case (0...) :
            10
        default:
            11
        }
    }
    
    private func shouldIncreaseIdx(_ category: Int, humidity: Int?) -> Bool {
        guard let humidity else { return false }
        return (category <= 2 && humidity >= 60) || (category > 2 && humidity >= 80)
    }
    
}

