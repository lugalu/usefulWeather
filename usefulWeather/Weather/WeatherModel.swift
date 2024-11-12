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
        guard let weatherData,
              let airTemperature = weatherData.temperature.real,
              let airVelocity = weatherData.wind.speed
        else { return }
        //TODO: tomorrow, make the HealthService, then bring it here
        // TODO: Change Air temperature from K to C and Velocity from m/s to cm/s
        let skinTemperature = 37.0 // use user bodyTemperature else the average
        let bodySurfaceArea = sqrt(1.76 * 77 / 3600) //BSA = the square root of [height (in centimeters) x weight (in kilograms) / 3600]. need to get these infos
        let metabolicRate = 65.0 //check healthKit for this, else use a average value (50 + 80)/2 where 50 is base average and 80 max average
        let evaporationLoss = 0.05 // we assume no evaporation loss
        let weight = 60.0 //weight of the person in kg
        
        
        //the formula goes as follows
        //first we calculate the InsulationOfAir
        let insulationOfAir = 1 / (0.61 * pow((airTemperature / 298),3) + 0.91 * sqrt(airVelocity) * 298 / airTemperature)
        
        //then we calculate the base insulationOfClothes
        var baseInsulation = 5.55 * (skinTemperature - airTemperature) * bodySurfaceArea
        let baseInsulationDenominator = metabolicRate - (0.58 * evaporationLoss) + (0.83 * weight)
        baseInsulation /= baseInsulationDenominator
        
        //Finally this is the result, we can use this to find good clothes!
        let result = baseInsulation - insulationOfAir
    }
    
}

